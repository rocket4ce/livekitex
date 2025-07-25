defmodule Livekitex.ConnectionPool do
  @moduledoc """
  Connection pool manager for gRPC connections to LiveKit server.

  This module provides connection pooling, automatic reconnection,
  and load balancing for gRPC connections to improve performance
  and reliability.
  """

  use GenServer
  require Logger
  alias Livekitex.{Config, Logger}

  @default_pool_size 10
  @default_max_overflow 5
  @default_reconnect_delay 1000
  @default_health_check_interval 30_000

  defstruct [
    :host,
    :pool_size,
    :max_overflow,
    :reconnect_delay,
    :health_check_interval,
    :connections,
    :available,
    :in_use,
    :overflow,
    :health_check_timer
  ]

  @type t :: %__MODULE__{
          host: String.t(),
          pool_size: non_neg_integer(),
          max_overflow: non_neg_integer(),
          reconnect_delay: non_neg_integer(),
          health_check_interval: non_neg_integer(),
          connections: map(),
          available: list(),
          in_use: map(),
          overflow: non_neg_integer(),
          health_check_timer: reference() | nil
        }

  # Public API

  @doc """
  Starts a connection pool for the given host.

  ## Parameters

  - `host` - LiveKit server host
  - `opts` - Pool options

  ## Options

  - `:pool_size` - Base pool size (default: 10)
  - `:max_overflow` - Maximum overflow connections (default: 5)
  - `:reconnect_delay` - Delay between reconnection attempts in ms (default: 1000)
  - `:health_check_interval` - Health check interval in ms (default: 30000)

  ## Examples

      {:ok, pid} = Livekitex.ConnectionPool.start_link("localhost:7880")

      {:ok, pid} = Livekitex.ConnectionPool.start_link(
        "localhost:7880",
        pool_size: 20,
        max_overflow: 10
      )
  """
  def start_link(host, opts \\ []) do
    GenServer.start_link(__MODULE__, {host, opts}, name: pool_name(host))
  end

  @doc """
  Gets a connection from the pool.

  ## Parameters

  - `host` - LiveKit server host
  - `timeout` - Checkout timeout in ms (default: 5000)

  ## Returns

  - `{:ok, connection}` - Successfully checked out connection
  - `{:error, :timeout}` - Timeout waiting for connection
  - `{:error, reason}` - Other error

  ## Examples

      {:ok, conn} = Livekitex.ConnectionPool.checkout("localhost:7880")
      # Use connection...
      Livekitex.ConnectionPool.checkin("localhost:7880", conn)
  """
  def checkout(host, timeout \\ 5000) do
    pool_pid = pool_name(host)

    try do
      GenServer.call(pool_pid, :checkout, timeout)
    catch
      :exit, {:timeout, _} ->
        {:error, :timeout}

      :exit, {:noproc, _} ->
        {:error, :pool_not_started}
    end
  end

  @doc """
  Returns a connection to the pool.

  ## Parameters

  - `host` - LiveKit server host
  - `connection` - Connection to return

  ## Examples

      {:ok, conn} = Livekitex.ConnectionPool.checkout("localhost:7880")
      # Use connection...
      :ok = Livekitex.ConnectionPool.checkin("localhost:7880", conn)
  """
  def checkin(host, connection) do
    pool_pid = pool_name(host)

    try do
      GenServer.cast(pool_pid, {:checkin, connection})
    catch
      :exit, {:noproc, _} ->
        # Pool is not running, close the connection
        close_connection(connection)
        :ok
    end
  end

  @doc """
  Executes a function with a connection from the pool.

  The connection is automatically checked out and returned to the pool.

  ## Parameters

  - `host` - LiveKit server host
  - `fun` - Function to execute with the connection
  - `timeout` - Checkout timeout in ms (default: 5000)

  ## Examples

      result = Livekitex.ConnectionPool.with_connection("localhost:7880", fn conn ->
        # Use connection...
        {:ok, response}
      end)
  """
  def with_connection(host, fun, timeout \\ 5000) do
    case checkout(host, timeout) do
      {:ok, connection} ->
        try do
          fun.(connection)
        after
          checkin(host, connection)
        end

      {:error, reason} ->
        {:error, reason}
    end
  end

  @doc """
  Gets pool statistics.

  ## Parameters

  - `host` - LiveKit server host

  ## Returns

  Map with pool statistics including:
  - `:pool_size` - Base pool size
  - `:available` - Number of available connections
  - `:in_use` - Number of connections in use
  - `:overflow` - Number of overflow connections

  ## Examples

      stats = Livekitex.ConnectionPool.stats("localhost:7880")
      # %{pool_size: 10, available: 8, in_use: 2, overflow: 0}
  """
  def stats(host) do
    pool_pid = pool_name(host)

    try do
      GenServer.call(pool_pid, :stats)
    catch
      :exit, {:noproc, _} ->
        %{error: :pool_not_started}
    end
  end

  @doc """
  Stops the connection pool.

  ## Parameters

  - `host` - LiveKit server host

  ## Examples

      :ok = Livekitex.ConnectionPool.stop("localhost:7880")
  """
  def stop(host) do
    pool_pid = pool_name(host)

    try do
      GenServer.stop(pool_pid)
    catch
      :exit, {:noproc, _} ->
        :ok
    end
  end

  # GenServer callbacks

  @impl true
  def init({host, opts}) do
    pool_size = Keyword.get(opts, :pool_size, @default_pool_size)
    max_overflow = Keyword.get(opts, :max_overflow, @default_max_overflow)
    reconnect_delay = Keyword.get(opts, :reconnect_delay, @default_reconnect_delay)

    health_check_interval =
      Keyword.get(opts, :health_check_interval, @default_health_check_interval)

    state = %__MODULE__{
      host: host,
      pool_size: pool_size,
      max_overflow: max_overflow,
      reconnect_delay: reconnect_delay,
      health_check_interval: health_check_interval,
      connections: %{},
      available: [],
      in_use: %{},
      overflow: 0,
      health_check_timer: nil
    }

    Logger.info("Starting connection pool", %{
      host: host,
      pool_size: pool_size,
      max_overflow: max_overflow
    })

    # Initialize pool connections
    {:ok, state, {:continue, :initialize_pool}}
  end

  @impl true
  def handle_continue(:initialize_pool, state) do
    # Create initial pool connections
    {connections, available} = create_initial_connections(state.host, state.pool_size)

    # Start health check timer
    health_check_timer = schedule_health_check(state.health_check_interval)

    new_state = %{
      state
      | connections: connections,
        available: available,
        health_check_timer: health_check_timer
    }

    Logger.info("Connection pool initialized", %{
      host: state.host,
      connections: map_size(connections),
      available: length(available)
    })

    {:noreply, new_state}
  end

  @impl true
  def handle_call(:checkout, from, state) do
    case get_connection(state) do
      {:ok, connection, new_state} ->
        # Track the connection as in use
        in_use = Map.put(new_state.in_use, connection, from)
        final_state = %{new_state | in_use: in_use}

        Logger.debug("Connection checked out", %{
          host: state.host,
          connection: inspect(connection),
          available: length(final_state.available),
          in_use: map_size(final_state.in_use)
        })

        {:reply, {:ok, connection}, final_state}

      {:error, reason, new_state} ->
        Logger.warning("Failed to checkout connection", %{
          host: state.host,
          reason: reason
        })

        {:reply, {:error, reason}, new_state}
    end
  end

  @impl true
  def handle_call(:stats, _from, state) do
    stats = %{
      pool_size: state.pool_size,
      max_overflow: state.max_overflow,
      available: length(state.available),
      in_use: map_size(state.in_use),
      overflow: state.overflow,
      total_connections: map_size(state.connections)
    }

    {:reply, stats, state}
  end

  @impl true
  def handle_cast({:checkin, connection}, state) do
    case Map.pop(state.in_use, connection) do
      {nil, _} ->
        # Connection not tracked, might be overflow or invalid
        Logger.debug("Checking in untracked connection", %{
          host: state.host,
          connection: inspect(connection)
        })

        if state.overflow > 0 and is_overflow_connection?(connection, state) do
          # Close overflow connection
          close_connection(connection)
          new_state = %{state | overflow: state.overflow - 1}
          {:noreply, new_state}
        else
          {:noreply, state}
        end

      {_from, in_use} ->
        # Return connection to available pool
        if connection_healthy?(connection) do
          available = [connection | state.available]
          new_state = %{state | available: available, in_use: in_use}

          Logger.debug("Connection checked in", %{
            host: state.host,
            connection: inspect(connection),
            available: length(available),
            in_use: map_size(in_use)
          })

          {:noreply, new_state}
        else
          # Connection is unhealthy, replace it
          Logger.warning("Unhealthy connection returned, replacing", %{
            host: state.host,
            connection: inspect(connection)
          })

          close_connection(connection)
          connections = Map.delete(state.connections, connection)

          # Create replacement connection
          case create_connection(state.host) do
            {:ok, new_connection} ->
              new_connections = Map.put(connections, new_connection, true)
              available = [new_connection | state.available]

              new_state = %{
                state
                | connections: new_connections,
                  available: available,
                  in_use: in_use
              }

              {:noreply, new_state}

            {:error, _reason} ->
              # Failed to create replacement, just remove the old one
              new_state = %{state | connections: connections, in_use: in_use}
              {:noreply, new_state}
          end
        end
    end
  end

  @impl true
  def handle_info(:health_check, state) do
    Logger.debug("Performing health check", %{host: state.host})

    # Check health of available connections
    {healthy_connections, unhealthy_connections} =
      Enum.split_with(state.available, &connection_healthy?/1)

    # Close unhealthy connections
    Enum.each(unhealthy_connections, &close_connection/1)

    # Remove unhealthy connections from tracking
    connections =
      Enum.reduce(unhealthy_connections, state.connections, fn conn, acc ->
        Map.delete(acc, conn)
      end)

    # Create replacement connections
    needed = length(unhealthy_connections)
    {new_connections, new_available} = create_connections(state.host, needed)

    final_connections = Map.merge(connections, new_connections)
    final_available = healthy_connections ++ new_available

    if needed > 0 do
      Logger.info("Replaced unhealthy connections", %{
        host: state.host,
        replaced: needed,
        available: length(final_available)
      })
    end

    # Schedule next health check
    health_check_timer = schedule_health_check(state.health_check_interval)

    new_state = %{
      state
      | connections: final_connections,
        available: final_available,
        health_check_timer: health_check_timer
    }

    {:noreply, new_state}
  end

  @impl true
  def handle_info({:DOWN, _ref, :process, pid, _reason}, state) do
    # Handle connection process termination
    Logger.warning("Connection process terminated", %{
      host: state.host,
      pid: inspect(pid)
    })

    # Remove from tracking and create replacement if needed
    case find_connection_by_pid(pid, state) do
      {:ok, connection} ->
        connections = Map.delete(state.connections, connection)
        available = List.delete(state.available, connection)
        in_use = Map.delete(state.in_use, connection)

        # Create replacement if it was a pool connection
        if map_size(connections) < state.pool_size do
          case create_connection(state.host) do
            {:ok, new_connection} ->
              new_connections = Map.put(connections, new_connection, true)
              new_available = [new_connection | available]

              new_state = %{
                state
                | connections: new_connections,
                  available: new_available,
                  in_use: in_use
              }

              {:noreply, new_state}

            {:error, _reason} ->
              new_state = %{
                state
                | connections: connections,
                  available: available,
                  in_use: in_use
              }

              {:noreply, new_state}
          end
        else
          new_state = %{state | connections: connections, available: available, in_use: in_use}
          {:noreply, new_state}
        end

      :not_found ->
        {:noreply, state}
    end
  end

  @impl true
  def terminate(_reason, state) do
    Logger.info("Stopping connection pool", %{host: state.host})

    # Cancel health check timer
    if state.health_check_timer do
      Process.cancel_timer(state.health_check_timer)
    end

    # Close all connections
    Enum.each(Map.keys(state.connections), &close_connection/1)

    :ok
  end

  # Private functions

  defp pool_name(host) do
    {:via, Registry, {Livekitex.ConnectionPoolRegistry, host}}
  end

  defp create_initial_connections(host, count) do
    {connections, available} = create_connections(host, count)

    Logger.debug("Created initial connections", %{
      host: host,
      requested: count,
      created: map_size(connections)
    })

    {connections, available}
  end

  defp create_connections(host, count) do
    1..count
    |> Enum.reduce({%{}, []}, fn _i, {connections, available} ->
      case create_connection(host) do
        {:ok, connection} ->
          new_connections = Map.put(connections, connection, true)
          new_available = [connection | available]
          {new_connections, new_available}

        {:error, reason} ->
          Logger.warning("Failed to create connection", %{
            host: host,
            reason: reason
          })

          {connections, available}
      end
    end)
  end

  defp create_connection(host) do
    case GRPC.Stub.connect(host, adapter_opts()) do
      {:ok, channel} ->
        # Monitor the connection process
        Process.monitor(channel.adapter_payload.conn_pid)

        Logger.debug("Created connection", %{
          host: host,
          connection: inspect(channel)
        })

        {:ok, channel}

      {:error, reason} ->
        Logger.error("Failed to create connection", %{
          host: host,
          reason: inspect(reason)
        })

        {:error, reason}
    end
  end

  defp adapter_opts do
    config = Config.get()

    opts = [
      timeout: config.timeout
    ]

    if config.use_tls do
      opts ++ [transport_opts: [verify: :verify_peer]]
    else
      opts
    end
  end

  defp get_connection(state) do
    case state.available do
      [connection | rest] ->
        # Use available connection
        new_state = %{state | available: rest}
        {:ok, connection, new_state}

      [] ->
        # No available connections, try overflow
        if state.overflow < state.max_overflow do
          case create_connection(state.host) do
            {:ok, connection} ->
              new_state = %{state | overflow: state.overflow + 1}
              {:ok, connection, new_state}

            {:error, reason} ->
              {:error, reason, state}
          end
        else
          {:error, :pool_exhausted, state}
        end
    end
  end

  defp connection_healthy?(connection) do
    try do
      # Simple health check - check if the connection process is alive
      case connection do
        %GRPC.Channel{adapter_payload: %{conn_pid: pid}} when is_pid(pid) ->
          Process.alive?(pid)

        _ ->
          false
      end
    rescue
      _ -> false
    catch
      _ -> false
    end
  end

  defp close_connection(connection) do
    try do
      GRPC.Stub.disconnect(connection)
    rescue
      _ -> :ok
    catch
      _ -> :ok
    end
  end

  defp is_overflow_connection?(connection, state) do
    not Map.has_key?(state.connections, connection)
  end

  defp find_connection_by_pid(pid, state) do
    Enum.find_value(Map.keys(state.connections), fn connection ->
      try do
        if connection.adapter_payload.conn_pid == pid do
          {:ok, connection}
        else
          nil
        end
      rescue
        _ -> nil
      catch
        _ -> nil
      end
    end) || :not_found
  end

  defp schedule_health_check(interval) do
    Process.send_after(self(), :health_check, interval)
  end
end

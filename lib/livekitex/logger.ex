defmodule Livekitex.Logger do
  @moduledoc """
  Structured logging system for LiveKit Elixir SDK.

  This module provides structured logging with telemetry integration,
  context tracking, and performance monitoring for LiveKit operations.
  """

  require Logger
  alias Livekitex.Config

  @doc """
  Logs a structured message with context and telemetry.

  ## Parameters

  - `level` - Log level (:debug, :info, :warning, :error)
  - `message` - Log message
  - `metadata` - Additional metadata (optional)

  ## Examples

      iex> Livekitex.Logger.log(:info, "Room created", %{room_name: "test-room", participants: 2})

      iex> Livekitex.Logger.log(:error, "Connection failed", %{host: "localhost:7880", error: "timeout"})
  """
  def log(level, message, metadata \\ %{}) do
    if should_log?(level) do
      structured_metadata = build_metadata(metadata)
      Logger.log(level, message, structured_metadata)

      if Config.get(:telemetry_enabled, true) do
        emit_telemetry_event(level, message, structured_metadata)
      end
    end
  end

  @doc """
  Logs debug information.

  ## Parameters

  - `message` - Debug message
  - `metadata` - Additional metadata (optional)
  """
  def debug(message, metadata \\ %{}) do
    log(:debug, message, metadata)
  end

  @doc """
  Logs informational messages.

  ## Parameters

  - `message` - Info message
  - `metadata` - Additional metadata (optional)
  """
  def info(message, metadata \\ %{}) do
    log(:info, message, metadata)
  end

  @doc """
  Logs warning messages.

  ## Parameters

  - `message` - Warning message
  - `metadata` - Additional metadata (optional)
  """
  def warning(message, metadata \\ %{}) do
    log(:warning, message, metadata)
  end

  @doc """
  Logs error messages.

  ## Parameters

  - `message` - Error message
  - `metadata` - Additional metadata (optional)
  """
  def error(message, metadata \\ %{}) do
    log(:error, message, metadata)
  end

  @doc """
  Logs the start of an operation and returns a timer function.

  ## Parameters

  - `operation` - Operation name
  - `metadata` - Additional metadata (optional)

  ## Returns

  A function that when called will log the operation completion with duration.

  ## Examples

      timer = Livekitex.Logger.start_operation("create_room", %{room_name: "test"})
      # ... perform operation ...
      timer.() # Logs completion with duration
  """
  def start_operation(operation, metadata \\ %{}) do
    start_time = System.monotonic_time(:millisecond)
    operation_id = generate_operation_id()

    operation_metadata =
      metadata
      |> Map.put(:operation, operation)
      |> Map.put(:operation_id, operation_id)

    debug("Operation started", operation_metadata)

    if Config.get(:telemetry_enabled, true) do
      :telemetry.execute(
        [:livekitex, :operation, :start],
        %{system_time: System.system_time()},
        operation_metadata
      )
    end

    fn ->
      end_time = System.monotonic_time(:millisecond)
      duration = end_time - start_time

      completion_metadata =
        operation_metadata
        |> Map.put(:duration_ms, duration)

      info("Operation completed", completion_metadata)

      if Config.get(:telemetry_enabled, true) do
        :telemetry.execute(
          [:livekitex, :operation, :stop],
          %{duration: duration, system_time: System.system_time()},
          completion_metadata
        )
      end

      duration
    end
  end

  @doc """
  Logs an operation with automatic timing.

  ## Parameters

  - `operation` - Operation name
  - `metadata` - Additional metadata (optional)
  - `fun` - Function to execute and time

  ## Returns

  The result of the function execution.

  ## Examples

      result = Livekitex.Logger.with_operation("create_room", %{room_name: "test"}, fn ->
        # ... perform operation ...
        {:ok, room}
      end)
  """
  def with_operation(operation, metadata \\ %{}, fun) do
    timer = start_operation(operation, metadata)

    try do
      result = fun.()
      timer.()
      result
    rescue
      error ->
        timer.()

        error_metadata =
          metadata
          |> Map.put(:operation, operation)
          |> Map.put(:error, inspect(error))

        error("Operation failed", error_metadata)
        reraise error, __STACKTRACE__
    end
  end

  @doc """
  Logs gRPC request/response information.

  ## Parameters

  - `service` - gRPC service name
  - `method` - gRPC method name
  - `request` - Request data (optional)
  - `response` - Response data (optional)
  - `metadata` - Additional metadata (optional)
  """
  def log_grpc_call(service, method, request \\ nil, response \\ nil, metadata \\ %{}) do
    grpc_metadata =
      metadata
      |> Map.put(:service, service)
      |> Map.put(:method, method)
      |> Map.put(:request_size, calculate_size(request))
      |> Map.put(:response_size, calculate_size(response))

    case response do
      {:ok, _} ->
        debug("gRPC call successful", grpc_metadata)

      {:error, error} ->
        error_metadata = Map.put(grpc_metadata, :error, inspect(error))
        warning("gRPC call failed", error_metadata)

      _ ->
        debug("gRPC call", grpc_metadata)
    end

    if Config.get(:telemetry_enabled, true) do
      :telemetry.execute(
        [:livekitex, :grpc, :call],
        %{system_time: System.system_time()},
        grpc_metadata
      )
    end
  end

  @doc """
  Logs webhook processing information.

  ## Parameters

  - `event_type` - Webhook event type
  - `processing_result` - Result of processing (:ok, :error, etc.)
  - `metadata` - Additional metadata (optional)
  """
  def log_webhook(event_type, processing_result, metadata \\ %{}) do
    webhook_metadata =
      metadata
      |> Map.put(:event_type, event_type)
      |> Map.put(:result, processing_result)

    case processing_result do
      :ok ->
        info("Webhook processed successfully", webhook_metadata)

      {:error, reason} ->
        error_metadata = Map.put(webhook_metadata, :error, inspect(reason))
        error("Webhook processing failed", error_metadata)

      _ ->
        info("Webhook processed", webhook_metadata)
    end

    if Config.get(:telemetry_enabled, true) do
      :telemetry.execute(
        [:livekitex, :webhook, :processed],
        %{system_time: System.system_time()},
        webhook_metadata
      )
    end
  end

  @doc """
  Logs connection events (connect, disconnect, reconnect).

  ## Parameters

  - `event` - Connection event (:connect, :disconnect, :reconnect)
  - `host` - Server host
  - `metadata` - Additional metadata (optional)
  """
  def log_connection(event, host, metadata \\ %{}) do
    connection_metadata =
      metadata
      |> Map.put(:event, event)
      |> Map.put(:host, host)

    case event do
      :connect ->
        info("Connected to LiveKit server", connection_metadata)

      :disconnect ->
        warning("Disconnected from LiveKit server", connection_metadata)

      :reconnect ->
        info("Reconnected to LiveKit server", connection_metadata)

      _ ->
        info("Connection event", connection_metadata)
    end

    if Config.get(:telemetry_enabled, true) do
      :telemetry.execute(
        [:livekitex, :connection, event],
        %{system_time: System.system_time()},
        connection_metadata
      )
    end
  end

  @doc """
  Sets up telemetry handlers for LiveKit events.

  This should be called during application startup to register
  telemetry event handlers.

  ## Examples

      Livekitex.Logger.setup_telemetry()
  """
  def setup_telemetry do
    events = [
      [:livekitex, :operation, :start],
      [:livekitex, :operation, :stop],
      [:livekitex, :grpc, :call],
      [:livekitex, :webhook, :processed],
      [:livekitex, :connection, :connect],
      [:livekitex, :connection, :disconnect],
      [:livekitex, :connection, :reconnect]
    ]

    :telemetry.attach_many(
      "livekitex-logger",
      events,
      &handle_telemetry_event/4,
      nil
    )

    info("Telemetry handlers attached", %{events: length(events)})
  end

  @doc """
  Removes telemetry handlers.

  ## Examples

      Livekitex.Logger.teardown_telemetry()
  """
  def teardown_telemetry do
    :telemetry.detach("livekitex-logger")
    info("Telemetry handlers detached")
  end

  # Private functions

  defp should_log?(level) do
    configured_level = Config.get(:log_level, :info)
    Logger.compare_levels(level, configured_level) != :lt
  end

  defp build_metadata(metadata) do
    base_metadata = %{
      timestamp: DateTime.utc_now(),
      pid: inspect(self()),
      node: Node.self(),
      library: "livekitex"
    }

    Map.merge(base_metadata, metadata)
  end

  defp emit_telemetry_event(level, message, metadata) do
    :telemetry.execute(
      [:livekitex, :log],
      %{system_time: System.system_time()},
      Map.merge(metadata, %{level: level, message: message})
    )
  end

  defp generate_operation_id do
    :crypto.strong_rand_bytes(8)
    |> Base.encode16(case: :lower)
  end

  defp calculate_size(nil), do: 0
  defp calculate_size(data) when is_binary(data), do: byte_size(data)
  defp calculate_size(data) when is_map(data), do: map_size(data)
  defp calculate_size(data) when is_list(data), do: length(data)
  defp calculate_size(_), do: 0

  defp handle_telemetry_event(event, measurements, metadata, _config) do
    case event do
      [:livekitex, :operation, :start] ->
        debug("Telemetry: Operation started", %{
          event: event,
          operation: metadata[:operation],
          operation_id: metadata[:operation_id]
        })

      [:livekitex, :operation, :stop] ->
        debug("Telemetry: Operation completed", %{
          event: event,
          operation: metadata[:operation],
          operation_id: metadata[:operation_id],
          duration: measurements[:duration]
        })

      [:livekitex, :grpc, :call] ->
        debug("Telemetry: gRPC call", %{
          event: event,
          service: metadata[:service],
          method: metadata[:method]
        })

      [:livekitex, :webhook, :processed] ->
        debug("Telemetry: Webhook processed", %{
          event: event,
          event_type: metadata[:event_type],
          result: metadata[:result]
        })

      [:livekitex, :connection, _] ->
        debug("Telemetry: Connection event", %{
          event: event,
          host: metadata[:host]
        })

      _ ->
        debug("Telemetry: Unknown event", %{event: event})
    end
  end
end

defmodule Livekitex.Config do
  @moduledoc """
  Configuration management for LiveKit Elixir SDK.

  This module provides centralized configuration management with support for
  different environments (dev, test, prod) and runtime configuration.
  """

  require Logger

  @default_config %{
    host: "localhost",
    use_tls: false,
    api_key: nil,
    api_secret: nil,
    timeout: 30_000,
    max_retries: 3,
    retry_delay: 1000,
    connection_pool_size: 10,
    connection_pool_max_overflow: 5,
    log_level: :info,
    telemetry_enabled: true,
    webhook_timeout: 5000
  }

  @doc """
  Gets the current configuration for the LiveKit SDK.

  Configuration is loaded from multiple sources in order of precedence:
  1. Runtime configuration (highest priority)
  2. Application environment
  3. System environment variables
  4. Default values (lowest priority)

  ## Examples

      iex> Livekitex.Config.get()
      %{
        host: "localhost:7880",
        use_tls: false,
        api_key: "your_api_key",
        api_secret: "your_api_secret",
        timeout: 30000,
        ...
      }
  """
  def get do
    @default_config
    |> merge_app_config()
    |> merge_env_config()
    |> merge_runtime_config()
    |> validate_config()
  end

  @doc """
  Gets a specific configuration value.

  ## Parameters

  - `key` - Configuration key (atom)
  - `default` - Default value if key is not found

  ## Examples

      iex> Livekitex.Config.get(:host)
      "localhost:7880"

      iex> Livekitex.Config.get(:custom_key, "default_value")
      "default_value"
  """
  def get(key, default \\ nil) do
    config = get()
    Map.get(config, key, default)
  end

  @doc """
  Sets a runtime configuration value.

  This allows for dynamic configuration changes at runtime.
  Runtime configuration has the highest precedence.

  ## Parameters

  - `key` - Configuration key (atom)
  - `value` - Configuration value

  ## Examples

      iex> Livekitex.Config.put(:host, "production.livekit.io:443")
      :ok

      iex> Livekitex.Config.put(:use_tls, true)
      :ok
  """
  def put(key, value) do
    runtime_config = get_runtime_config()
    new_config = Map.put(runtime_config, key, value)
    :persistent_term.put({__MODULE__, :runtime_config}, new_config)
    Logger.debug("Updated runtime config: #{key} = #{inspect(value)}")
    :ok
  end

  @doc """
  Gets the configuration for a specific environment.

  ## Parameters

  - `env` - Environment atom (:dev, :test, :prod)

  ## Examples

      iex> Livekitex.Config.get_env_config(:prod)
      %{host: "livekit.example.com:443", use_tls: true, ...}
  """
  def get_env_config(env) do
    case env do
      :dev ->
        %{
          host: "localhost:7880",
          use_tls: false,
          log_level: :debug,
          telemetry_enabled: true,
          timeout: 10_000
        }

      :test ->
        %{
          host: "localhost:7880",
          use_tls: false,
          log_level: :warning,
          telemetry_enabled: false,
          timeout: 5_000,
          max_retries: 1
        }

      :prod ->
        %{
          use_tls: true,
          log_level: :info,
          telemetry_enabled: true,
          timeout: 30_000,
          max_retries: 5,
          retry_delay: 2000
        }

      _ ->
        %{}
    end
  end

  @doc """
  Validates the current configuration.

  ## Returns

  - `{:ok, config}` - Configuration is valid
  - `{:error, reason}` - Configuration is invalid

  ## Examples

      iex> Livekitex.Config.validate()
      {:ok, %{host: "localhost:7880", ...}}

      iex> Livekitex.Config.validate()
      {:error, "API key is required"}
  """
  def validate do
    config = get()
    validate_config(config)
  end

  @doc """
  Resets runtime configuration to defaults.

  This removes all runtime configuration overrides.

  ## Examples

      iex> Livekitex.Config.reset()
      :ok
  """
  def reset do
    :persistent_term.erase({__MODULE__, :runtime_config})
    Logger.debug("Reset runtime configuration")
    :ok
  end

  @doc """
  Creates a client configuration map from the current config.

  This is useful for creating service clients with the current configuration.

  ## Examples

      iex> Livekitex.Config.client_config()
      %{
        api_key: "your_api_key",
        api_secret: "your_api_secret",
        host: "localhost:7880"
      }
  """
  def client_config do
    config = get()

    %{
      api_key: config.api_key,
      api_secret: config.api_secret,
      host: config.host
    }
  end

  @doc """
  Gets gRPC connection options from the current configuration.

  ## Examples

      iex> Livekitex.Config.grpc_options()
      [
        timeout: 30000,
        max_retries: 3,
        retry_delay: 1000,
        pool_size: 10,
        pool_max_overflow: 5
      ]
  """
  def grpc_options do
    config = get()

    [
      timeout: config.timeout,
      max_retries: config.max_retries,
      retry_delay: config.retry_delay,
      pool_size: config.connection_pool_size,
      pool_max_overflow: config.connection_pool_max_overflow
    ]
  end

  # Private functions

  defp merge_app_config(config) do
    app_config = Application.get_all_env(:livekitex)
    Map.merge(config, Map.new(app_config))
  end

  defp merge_env_config(config) do
    env_config = %{
      host: System.get_env("LIVEKIT_HOST"),
      api_key: System.get_env("LIVEKIT_API_KEY"),
      api_secret: System.get_env("LIVEKIT_API_SECRET"),
      use_tls: parse_boolean(System.get_env("LIVEKIT_USE_TLS")),
      timeout: parse_integer(System.get_env("LIVEKIT_TIMEOUT")),
      max_retries: parse_integer(System.get_env("LIVEKIT_MAX_RETRIES")),
      retry_delay: parse_integer(System.get_env("LIVEKIT_RETRY_DELAY")),
      connection_pool_size: parse_integer(System.get_env("LIVEKIT_POOL_SIZE")),
      connection_pool_max_overflow: parse_integer(System.get_env("LIVEKIT_POOL_MAX_OVERFLOW")),
      log_level: parse_log_level(System.get_env("LIVEKIT_LOG_LEVEL")),
      telemetry_enabled: parse_boolean(System.get_env("LIVEKIT_TELEMETRY_ENABLED")),
      webhook_timeout: parse_integer(System.get_env("LIVEKIT_WEBHOOK_TIMEOUT"))
    }

    # Remove nil values
    env_config = Map.reject(env_config, fn {_k, v} -> is_nil(v) end)

    # Merge environment-specific config
    current_env = Application.get_env(:livekitex, :environment, Mix.env())
    env_specific_config = get_env_config(current_env)

    config
    |> Map.merge(env_specific_config)
    |> Map.merge(env_config)
  end

  defp merge_runtime_config(config) do
    runtime_config = get_runtime_config()
    Map.merge(config, runtime_config)
  end

  defp get_runtime_config do
    case :persistent_term.get({__MODULE__, :runtime_config}, nil) do
      nil -> %{}
      config -> config
    end
  end

  defp validate_config(config) do
    cond do
      is_nil(config.api_key) ->
        Logger.warning("API key is not configured")
        {:error, "API key is required"}

      is_nil(config.api_secret) ->
        Logger.warning("API secret is not configured")
        {:error, "API secret is required"}

      is_nil(config.host) ->
        Logger.warning("Host is not configured")
        {:error, "Host is required"}

      config.timeout <= 0 ->
        Logger.warning("Invalid timeout value: #{config.timeout}")
        {:error, "Timeout must be positive"}

      config.max_retries < 0 ->
        Logger.warning("Invalid max_retries value: #{config.max_retries}")
        {:error, "Max retries must be non-negative"}

      config.retry_delay < 0 ->
        Logger.warning("Invalid retry_delay value: #{config.retry_delay}")
        {:error, "Retry delay must be non-negative"}

      config.connection_pool_size <= 0 ->
        Logger.warning("Invalid connection_pool_size value: #{config.connection_pool_size}")
        {:error, "Connection pool size must be positive"}

      config.connection_pool_max_overflow < 0 ->
        Logger.warning(
          "Invalid connection_pool_max_overflow value: #{config.connection_pool_max_overflow}"
        )

        {:error, "Connection pool max overflow must be non-negative"}

      true ->
        config
    end
  end

  defp parse_boolean(nil), do: nil
  defp parse_boolean("true"), do: true
  defp parse_boolean("false"), do: false
  defp parse_boolean("1"), do: true
  defp parse_boolean("0"), do: false
  defp parse_boolean(_), do: nil

  defp parse_integer(nil), do: nil

  defp parse_integer(value) when is_binary(value) do
    case Integer.parse(value) do
      {int, ""} -> int
      _ -> nil
    end
  end

  defp parse_integer(_), do: nil

  defp parse_log_level(nil), do: nil
  defp parse_log_level("debug"), do: :debug
  defp parse_log_level("info"), do: :info
  defp parse_log_level("warning"), do: :warning
  defp parse_log_level("warn"), do: :warning
  defp parse_log_level("error"), do: :error
  defp parse_log_level(_), do: nil
end

defmodule Livekitex.Config do
  @moduledoc """
  Configuration for the LiveKit SDK.

  Values are resolved in this order (first match wins):

    1. Runtime overrides set with `put/2`
    2. Application environment (`config :livekitex, ...`)
    3. System environment variables (`LIVEKIT_URL`, `LIVEKIT_API_KEY`, `LIVEKIT_API_SECRET`)
    4. Defaults

  ## Keys

    * `:url` - LiveKit server URL. `ws://`, `wss://`, `http://` and `https://` are
      accepted, e.g. `"wss://my-project.livekit.cloud"` or `"http://localhost:7880"`.
    * `:api_key` / `:api_secret` - API credentials.
    * `:timeout` - per-request receive timeout in milliseconds. Defaults to `10_000`.
    * `:retry` - `true` (default), `false`, or a keyword list with `:max_attempts`
      and `:base_delay` (ms). See `Livekitex.Twirp`.

  For backwards compatibility `:host`, `:port` and `:use_tls` are still accepted and
  converted to `:url` when `:url` is not set.

  ## Example

      # config/runtime.exs
      config :livekitex,
        url: System.fetch_env!("LIVEKIT_URL"),
        api_key: System.fetch_env!("LIVEKIT_API_KEY"),
        api_secret: System.fetch_env!("LIVEKIT_API_SECRET")
  """

  @keys [:url, :api_key, :api_secret, :timeout, :retry, :host, :port, :use_tls]

  @defaults %{
    url: nil,
    api_key: nil,
    api_secret: nil,
    timeout: 10_000,
    retry: true
  }

  @env_vars %{
    url: "LIVEKIT_URL",
    api_key: "LIVEKIT_API_KEY",
    api_secret: "LIVEKIT_API_SECRET"
  }

  @runtime_key {__MODULE__, :runtime}

  @doc """
  Returns the resolved configuration map.

  > #### The map holds the API secret {: .warning}
  >
  > Unlike `Livekitex.Client`, this is a plain map with no `Inspect` protection, so
  > `inspect/1` on it (in a log line, an error report or a crash dump) prints the
  > secret. Read single values with `get/2` instead of dumping the whole map.
  """
  @spec get() :: map()
  def get do
    runtime = :persistent_term.get(@runtime_key, %{})

    app =
      :livekitex
      |> Application.get_all_env()
      |> Keyword.take(@keys)
      |> Map.new()
      |> legacy_url()

    env =
      for {key, var} <- @env_vars,
          value = System.get_env(var),
          value not in [nil, ""],
          into: %{},
          do: {key, value}

    @defaults
    |> Map.merge(env)
    |> Map.merge(drop_nils(app))
    |> Map.merge(runtime |> legacy_url() |> drop_nils())
    |> Map.drop([:host, :port, :use_tls])
  end

  @doc "Returns a single configuration value."
  @spec get(atom(), term()) :: term()
  def get(key, default \\ nil), do: Map.get(get(), key, default)

  @doc """
  Sets a runtime override. Runtime overrides take precedence over everything else.
  """
  @spec put(atom(), term()) :: :ok
  def put(key, value) when key in @keys do
    runtime = :persistent_term.get(@runtime_key, %{})
    :persistent_term.put(@runtime_key, Map.put(runtime, key, value))
  end

  @doc "Removes all runtime overrides."
  @spec reset() :: :ok
  def reset do
    :persistent_term.erase(@runtime_key)
    :ok
  end

  @doc """
  Validates that credentials are present.
  """
  @spec validate() :: :ok | {:error, String.t()}
  def validate do
    config = get()

    cond do
      blank?(config.api_key) -> {:error, "LiveKit api_key is not configured"}
      blank?(config.api_secret) -> {:error, "LiveKit api_secret is not configured"}
      blank?(config.url) -> {:error, "LiveKit url is not configured"}
      true -> :ok
    end
  end

  defp legacy_url(%{url: url} = config) when is_binary(url), do: config

  defp legacy_url(%{host: host} = config) when is_binary(host) do
    scheme = if Map.get(config, :use_tls), do: "https", else: "http"

    url =
      cond do
        String.contains?(host, "://") -> host
        port = Map.get(config, :port) -> "#{scheme}://#{strip_port(host)}:#{port}"
        true -> "#{scheme}://#{host}"
      end

    Map.put(config, :url, url)
  end

  defp legacy_url(config), do: config

  defp strip_port(host), do: host |> String.split(":") |> hd()

  defp drop_nils(map), do: for({k, v} <- map, not is_nil(v), into: %{}, do: {k, v})

  defp blank?(value), do: value in [nil, ""]
end

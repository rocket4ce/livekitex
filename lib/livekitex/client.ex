defmodule Livekitex.Client do
  @moduledoc """
  Connection settings shared by every LiveKit service module.

  A client is a plain struct, so it is cheap to build and safe to keep in a module
  attribute, an Agent or your own process state.

      client = Livekitex.Client.new(url: "wss://my-project.livekit.cloud",
                                    api_key: "API...", api_secret: "...")

      {:ok, room} = Livekitex.RoomService.create_room(client, "standup")

  Any option not given falls back to `Livekitex.Config`, so with application config in
  place `Livekitex.Client.new()` (or `Livekitex.client()`) is enough.

  ## Options

    * `:url` - server URL. `ws://` and `wss://` are rewritten to `http://` and `https://`.
      A bare `host:port` is treated as `http://host:port`. A path is kept, so LiveKit can
      sit behind a path-prefixed reverse proxy.
    * `:api_key`, `:api_secret` - API credentials.
    * `:timeout` - receive timeout in milliseconds (default `10_000`).
    * `:retry` - retry policy, see `Livekitex.Twirp`.
    * `:req_options` - extra options merged into every `Req` request. Useful for
      custom Finch pools, proxies, or `plug: {Req.Test, MyStub}` in tests.
    * `:host`, `:port`, `:use_tls` - legacy alternative to `:url`.
  """

  alias Livekitex.Config

  @derive {Inspect, except: [:api_secret]}
  @enforce_keys [:base_url, :api_key, :api_secret]
  defstruct [:base_url, :api_key, :api_secret, timeout: 10_000, retry: true, req_options: []]

  @type retry :: boolean() | [max_attempts: pos_integer(), base_delay: non_neg_integer()]

  @type t :: %__MODULE__{
          base_url: String.t(),
          api_key: String.t(),
          api_secret: String.t(),
          timeout: pos_integer(),
          retry: retry(),
          req_options: keyword()
        }

  @doc """
  Builds a client from options, falling back to `Livekitex.Config`.

  Raises `ArgumentError` if the URL or credentials are missing.
  """
  @spec new(keyword()) :: t()
  def new(opts \\ []) do
    config = Config.get()
    url = opts[:url] || legacy_url(opts) || config.url
    api_key = opts[:api_key] || config.api_key
    api_secret = opts[:api_secret] || config.api_secret

    if url in [nil, ""] do
      raise ArgumentError,
            "LiveKit url is required (pass :url or set config :livekitex, url: ... / LIVEKIT_URL)"
    end

    if api_key in [nil, ""] or api_secret in [nil, ""] do
      raise ArgumentError,
            "LiveKit api_key and api_secret are required (pass them or set config :livekitex)"
    end

    %__MODULE__{
      base_url: normalize_url(url),
      api_key: api_key,
      api_secret: api_secret,
      timeout: opts[:timeout] || config.timeout,
      retry: Keyword.get(opts, :retry, config.retry),
      req_options: Keyword.get(opts, :req_options, [])
    }
  end

  @doc """
  Normalizes a LiveKit URL into the HTTP base URL used for Twirp calls.

      iex> Livekitex.Client.normalize_url("wss://demo.livekit.cloud/")
      "https://demo.livekit.cloud"

      iex> Livekitex.Client.normalize_url("ws://localhost:7880")
      "http://localhost:7880"

      iex> Livekitex.Client.normalize_url("localhost:7880")
      "http://localhost:7880"

      iex> Livekitex.Client.normalize_url("https://proxy.example.com/livekit/")
      "https://proxy.example.com/livekit"

      iex> Livekitex.Client.normalize_url("ws://[::1]:7880")
      "http://[::1]:7880"
  """
  @spec normalize_url(String.t()) :: String.t()
  def normalize_url(url) when is_binary(url) do
    url = String.trim(url)
    url = if String.contains?(url, "://"), do: url, else: "http://" <> url
    uri = URI.parse(url)
    scheme = http_scheme(uri.scheme)

    if uri.host in [nil, ""], do: raise(ArgumentError, "invalid LiveKit URL: #{inspect(url)}")

    host = if String.contains?(uri.host, ":"), do: "[#{uri.host}]", else: uri.host
    path = String.trim_trailing(uri.path || "", "/")

    "#{scheme}://#{host}#{port_suffix(scheme, uri.port)}#{path}"
  end

  def normalize_url(other), do: raise(ArgumentError, "invalid LiveKit URL: #{inspect(other)}")

  defp http_scheme("ws"), do: "http"
  defp http_scheme("wss"), do: "https"
  defp http_scheme(scheme) when scheme in ["http", "https"], do: scheme

  defp http_scheme(scheme),
    do: raise(ArgumentError, "unsupported LiveKit URL scheme: #{inspect(scheme)}")

  defp port_suffix("http", 80), do: ""
  defp port_suffix("https", 443), do: ""
  defp port_suffix(_scheme, nil), do: ""
  defp port_suffix(_scheme, port), do: ":#{port}"

  defp legacy_url(opts) do
    case opts[:host] do
      nil ->
        nil

      host ->
        scheme = if opts[:use_tls], do: "https", else: "http"
        port = opts[:port]

        cond do
          String.contains?(host, "://") -> host
          port -> "#{scheme}://#{host |> String.split(":") |> hd()}:#{port}"
          true -> "#{scheme}://#{host}"
        end
    end
  end
end

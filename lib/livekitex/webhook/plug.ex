defmodule Livekitex.Webhook.Plug do
  @moduledoc """
  A Plug that receives LiveKit webhooks, verifies them and hands each event to your
  handler.

      # Phoenix router
      forward "/livekit/webhook", Livekitex.Webhook.Plug, handler: MyApp.LiveKitWebhooks

      defmodule MyApp.LiveKitWebhooks do
        @behaviour Livekitex.Webhook.Handler

        @impl true
        def handle_event(%{event: "participant_joined", participant: p}, _conn) do
          Logger.info("joined: \#{p.identity}")
          :ok
        end

        def handle_event(_event, _conn), do: :ok
      end

  In Phoenix the endpoint's `Plug.Parsers` runs before the router; configure
  `Livekitex.Webhook.BodyReader` as its `:body_reader` so the raw body is available.
  Outside Phoenix, mount this plug before `Plug.Parsers` and it reads the body itself.

  ## Options

    * `:handler` (required) - a module implementing `Livekitex.Webhook.Handler`, or a
      function `fn event, conn -> ... end`
    * `:api_key`, `:api_secret`, `:keys`, `:leeway` - see `Livekitex.Webhook.receive_event/3`
    * `:max_body_length` - maximum body size in bytes (default 1_000_000)

  ## Responses

    * `200` - event verified and handled
    * `400` - body is not a valid webhook event
    * `401` - signature, issuer, expiry or body hash check failed
    * `405` - not a `POST`
    * `413` - body exceeds `:max_body_length`
    * `500` - the handler returned `{:error, _}`
  """

  @behaviour Plug

  import Plug.Conn

  alias Livekitex.Webhook
  alias Livekitex.Webhook.BodyReader

  require Logger

  @default_max_body 1_000_000

  @impl Plug
  def init(opts) do
    handler = Keyword.fetch!(opts, :handler)

    unless is_function(handler, 2) or is_atom(handler) do
      raise ArgumentError, ":handler must be a module or a 2-arity function"
    end

    Keyword.put_new(opts, :max_body_length, @default_max_body)
  end

  @impl Plug
  def call(%Plug.Conn{method: "POST"} = conn, opts) do
    with {:ok, body, conn} <- raw_body(conn, opts[:max_body_length]),
         auth = conn |> get_req_header("authorization") |> List.first(),
         {:ok, event} <-
           Webhook.receive_event(
             body,
             auth,
             Keyword.take(opts, [:api_key, :api_secret, :keys, :leeway])
           ) do
      case run_handler(opts[:handler], event, conn) do
        {:error, reason} ->
          Logger.error("LiveKit webhook handler failed: #{inspect(reason)}")
          conn |> send_resp(500, "handler error") |> halt()

        _ ->
          conn |> send_resp(200, "ok") |> halt()
      end
    else
      {:error, :too_large, conn} ->
        conn |> send_resp(413, "payload too large") |> halt()

      {:error, {:invalid_body, _}} ->
        conn |> send_resp(400, "invalid webhook body") |> halt()

      {:error, :read_error, conn} ->
        conn |> send_resp(400, "could not read body") |> halt()

      {:error, reason} ->
        Logger.warning("Rejected LiveKit webhook: #{inspect(reason)}")
        conn |> send_resp(401, "unauthorized") |> halt()
    end
  end

  def call(conn, _opts) do
    conn |> put_resp_header("allow", "POST") |> send_resp(405, "method not allowed") |> halt()
  end

  defp run_handler(fun, event, conn) when is_function(fun, 2), do: fun.(event, conn)
  defp run_handler(module, event, conn), do: module.handle_event(event, conn)

  defp raw_body(conn, max) do
    case BodyReader.raw_body(conn) do
      body when is_binary(body) -> check_size(body, max, conn)
      nil -> read_all(conn, max, [])
    end
  end

  defp check_size(body, max, conn) when byte_size(body) > max, do: {:error, :too_large, conn}
  defp check_size(body, _max, conn), do: {:ok, body, conn}

  defp read_all(conn, max, acc) do
    case read_body(conn, length: max + 1) do
      {:ok, chunk, conn} ->
        [chunk | acc] |> Enum.reverse() |> IO.iodata_to_binary() |> check_size(max, conn)

      {:more, _chunk, conn} ->
        {:error, :too_large, conn}

      {:error, _} ->
        {:error, :read_error, conn}
    end
  end
end

defmodule Livekitex.Webhook.Handler do
  @moduledoc """
  Behaviour for modules that handle events received by `Livekitex.Webhook.Plug`.

  Return `{:error, reason}` to answer with HTTP 500 (LiveKit retries failed
  deliveries); any other value answers 200.
  """

  @callback handle_event(Livekitex.Proto.Livekit.WebhookEvent.t(), Plug.Conn.t()) :: term()
end

defmodule Livekitex.Webhook.BodyReader do
  @moduledoc """
  A `Plug.Parsers` body reader that keeps the raw body, so webhooks can still be
  verified after the body has been parsed.

  `Plug.Parsers.JSON` accepts `application/webhook+json`, so in a Phoenix app the
  endpoint parses (and consumes) the webhook body before it reaches your router.
  Configure the parsers to keep a copy:

      # lib/my_app_web/endpoint.ex
      plug Plug.Parsers,
        parsers: [:urlencoded, :multipart, :json],
        pass: ["*/*"],
        json_decoder: Phoenix.json_library(),
        body_reader: {Livekitex.Webhook.BodyReader, :read_body, []}

  Only bodies sent with `Content-Type: application/webhook+json` are kept. The raw
  body is stored in `conn.private[:livekitex_raw_body]`, where
  `Livekitex.Webhook.Plug` picks it up; read it yourself with `raw_body/1`.
  """

  @private_key :livekitex_raw_body

  @doc "Reads the body like `Plug.Conn.read_body/2` and keeps a copy of webhook bodies."
  @spec read_body(Plug.Conn.t(), keyword()) ::
          {:ok, binary(), Plug.Conn.t()} | {:more, binary(), Plug.Conn.t()} | {:error, term()}
  def read_body(conn, opts) do
    case Plug.Conn.read_body(conn, opts) do
      {:ok, chunk, conn} -> {:ok, chunk, maybe_store(conn, chunk)}
      {:more, chunk, conn} -> {:more, chunk, maybe_store(conn, chunk)}
      {:error, _} = error -> error
    end
  end

  @doc "Returns the raw body stored by `read_body/2`, or `nil`."
  @spec raw_body(Plug.Conn.t()) :: binary() | nil
  def raw_body(%Plug.Conn{private: private}) do
    case Map.get(private, @private_key) do
      nil -> nil
      chunks -> chunks |> Enum.reverse() |> IO.iodata_to_binary()
    end
  end

  defp maybe_store(conn, chunk) do
    if webhook?(conn) do
      chunks = Map.get(conn.private, @private_key, [])
      Plug.Conn.put_private(conn, @private_key, [chunk | chunks])
    else
      conn
    end
  end

  defp webhook?(conn) do
    conn
    |> Plug.Conn.get_req_header("content-type")
    |> Enum.any?(&String.starts_with?(String.downcase(&1), "application/webhook+json"))
  end
end

defmodule Livekitex.TestHelpers do
  @moduledoc false

  @stub Livekitex.TwirpStub
  @api_key "devkey"
  @api_secret "secret"

  def api_key, do: @api_key
  def api_secret, do: @api_secret
  def stub_name, do: @stub

  @doc "A client whose requests go to the `Req.Test` stub."
  def client(opts \\ []) do
    Livekitex.Client.new(
      Keyword.merge(
        [
          url: "https://lk.test",
          api_key: @api_key,
          api_secret: @api_secret,
          retry: [base_delay: 1],
          req_options: [plug: {Req.Test, @stub}]
        ],
        opts
      )
    )
  end

  @doc """
  Stubs a single Twirp response. Every request is reported to the calling test
  process as `{:twirp, info}` with the path, raw body, decoded JWT claims and headers.
  """
  def stub_response(response) do
    test_pid = self()

    Req.Test.stub(@stub, fn conn ->
      {:ok, body, conn} = Plug.Conn.read_body(conn)
      send(test_pid, {:twirp, request_info(conn, body)})
      respond(conn, response)
    end)
  end

  @doc "Stubs a sequence of responses, one per request."
  def stub_sequence(responses) do
    test_pid = self()
    {:ok, agent} = Agent.start_link(fn -> responses end)

    Req.Test.stub(@stub, fn conn ->
      {:ok, body, conn} = Plug.Conn.read_body(conn)
      send(test_pid, {:twirp, request_info(conn, body)})
      response = Agent.get_and_update(agent, fn [h | t] -> {h, if(t == [], do: [h], else: t)} end)
      respond(conn, response)
    end)
  end

  defp respond(conn, {:twirp_error, status, code, msg, meta}) do
    conn
    |> Plug.Conn.put_resp_content_type("application/json")
    |> Plug.Conn.send_resp(status, Jason.encode!(%{code: code, msg: msg, meta: meta}))
  end

  defp respond(conn, {:raw, status, body}), do: Plug.Conn.send_resp(conn, status, body)

  defp respond(conn, {:transport_error, reason}), do: Req.Test.transport_error(conn, reason)

  defp respond(conn, %_{} = message) do
    conn
    |> Plug.Conn.put_resp_content_type("application/protobuf")
    |> Plug.Conn.send_resp(200, Protobuf.encode(message))
  end

  defp request_info(conn, body) do
    auth = conn |> Plug.Conn.get_req_header("authorization") |> List.first()
    "Bearer " <> jwt = auth
    {:ok, claims} = Joken.peek_claims(jwt)

    %{
      path: conn.request_path,
      method: conn.method,
      body: body,
      claims: claims,
      jwt: jwt,
      headers: Map.new(conn.req_headers)
    }
  end

  @doc "Signs a webhook body the way LiveKit does."
  def sign_webhook(body, opts \\ []) do
    hash = :crypto.hash(:sha256, body) |> Base.encode64()

    Livekitex.AccessToken.create(
      Keyword.get(opts, :api_key, @api_key),
      Keyword.get(opts, :api_secret, @api_secret),
      ttl: Keyword.get(opts, :ttl, 300)
    )
    |> Livekitex.AccessToken.set_sha256(Keyword.get(opts, :sha256, hash))
    |> Livekitex.AccessToken.to_jwt!()
  end
end

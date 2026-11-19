defmodule Livekitex.TokenSource.PlugTest do
  use ExUnit.Case, async: true

  import Plug.Test
  import Plug.Conn

  alias Livekitex.TokenSource.Plug, as: TokenSourcePlug
  alias Livekitex.TokenVerifier

  @base [api_key: "devkey", api_secret: "secret", server_url: "wss://lk.example.com"]

  defp request(body, opts) do
    conn(:post, "/token", Jason.encode!(body))
    |> put_req_header("content-type", "application/json")
    |> TokenSourcePlug.call(TokenSourcePlug.init(Keyword.merge(@base, opts)))
  end

  defp verify(conn) do
    %{"server_url" => url, "participant_token" => jwt} = Jason.decode!(conn.resp_body)
    {:ok, grant} = TokenVerifier.verify(TokenVerifier.new("devkey", "secret"), jwt)
    {url, grant}
  end

  test "issues a token from the authorize callback" do
    authorize = fn _conn, request ->
      {:ok,
       identity: "user-1", name: "User", room: request.room_name, video: [can_publish: false]}
    end

    conn =
      request(
        %{
          "room_name" => "lobby",
          "participant_identity" => "spoofed",
          "room_config" => %{"agents" => [%{"agent_name" => "a"}]}
        },
        authorize: authorize
      )

    assert conn.status == 201
    assert ["application/json" <> _] = get_resp_header(conn, "content-type")

    {url, grant} = verify(conn)
    assert url == "wss://lk.example.com"
    assert grant.identity == "user-1"
    assert grant.name == "User"
    assert grant.video.room_join
    assert grant.video.room == "lobby"
    assert grant.video.can_publish == false
    # client room_config ignored unless allowed
    assert grant.room_config == nil
  end

  test "passes the client's room_config through when allowed (camelCase accepted)" do
    conn =
      request(%{"roomName" => "r", "roomConfig" => %{"agents" => [%{"agentName" => "a"}]}},
        authorize: fn _, _ -> {:ok, identity: "u"} end,
        allow_room_config: true
      )

    {_url, grant} = verify(conn)
    assert grant.video.room == "r"
    assert [%{agent_name: "a"}] = grant.room_config.agents
  end

  test "propagates rejection status" do
    conn = request(%{}, authorize: fn _, _ -> {:error, 401} end)
    assert conn.status == 401
  end

  test "rejects invalid JSON" do
    conn =
      conn(:post, "/token", "{nope")
      |> put_req_header("content-type", "application/json")
      |> TokenSourcePlug.call(
        TokenSourcePlug.init(Keyword.put(@base, :authorize, fn _, _ -> {:ok, identity: "u"} end))
      )

    assert conn.status == 400
  end

  test "rejects non-POST" do
    conn =
      conn(:get, "/token")
      |> TokenSourcePlug.call(
        TokenSourcePlug.init(Keyword.put(@base, :authorize, fn _, _ -> :ok end))
      )

    assert conn.status == 405
  end
end

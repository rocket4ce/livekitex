defmodule Livekitex.HardeningTest do
  @moduledoc "Regression tests for issues found in the 0.2.0 release review."
  use ExUnit.Case, async: false

  import Livekitex.TestHelpers
  import Plug.Test
  import Plug.Conn

  alias Livekitex.{
    AccessToken,
    Client,
    Config,
    Error,
    RoomService,
    Service,
    TokenVerifier,
    Webhook
  }

  alias Livekitex.Proto.Livekit, as: LK
  alias Livekitex.TokenSource.Plug, as: TokenSourcePlug

  setup do
    on_exit(&Config.reset/0)
  end

  describe "secrets" do
    test "inspect never prints the API secret" do
      for struct <- [
            client(api_secret: "TOP-SECRET"),
            AccessToken.create("k", "TOP-SECRET"),
            TokenVerifier.new("k", "TOP-SECRET")
          ] do
        refute inspect(struct) =~ "TOP-SECRET"
      end
    end

    test "room config with storage credentials is refused unless allowed" do
      token =
        AccessToken.create("devkey", "secret", identity: "a")
        |> AccessToken.set_video_grant(room_join: true, room: "r")
        |> AccessToken.set_room_config(
          egress: [room: [file_outputs: [[s3: [access_key: "AK", secret: "S3SECRET"]]]]]
        )

      assert {:error, :sensitive_credentials} = AccessToken.to_jwt(token)

      assert {:ok, _jwt, claims} =
               AccessToken.to_jwt(%{token | allow_sensitive_credentials: true})

      assert get_in(claims, ["roomConfig", "egress"])

      raw =
        AccessToken.set_room_config(token, %{"egress" => %{"room" => %{"streamOutputs" => [%{}]}}})

      assert {:error, :sensitive_credentials} = AccessToken.to_jwt(raw)

      agents_only = AccessToken.set_room_config(token, agents: [[agent_name: "a"]])
      assert {:ok, _, _} = AccessToken.to_jwt(agents_only)
    end

    test "missing secret is an error, not an exception" do
      assert {:error, :missing_api_secret} =
               AccessToken.create("k", nil)
               |> AccessToken.set_video_grant(room_list: true)
               |> AccessToken.to_jwt()
    end
  end

  describe "TokenSource plug" do
    defp token_request(body, authorize) do
      conn(:post, "/token", Jason.encode!(body))
      |> put_req_header("content-type", "application/json")
      |> TokenSourcePlug.call(
        TokenSourcePlug.init(
          api_key: "devkey",
          api_secret: "secret",
          server_url: "wss://x",
          authorize: authorize
        )
      )
    end

    test "refuses to mint a join token without a room" do
      assert token_request(%{}, fn _, _ -> {:ok, identity: "u"} end).status == 400

      assert token_request(%{"room_name" => ""}, fn _, _ -> {:ok, identity: "u"} end).status ==
               400
    end

    test "uses a room given in the video options" do
      conn = token_request(%{}, fn _, _ -> {:ok, identity: "u", video: [room: "r9"]} end)
      assert conn.status == 201
      %{"participant_token" => jwt} = Jason.decode!(conn.resp_body)

      assert {:ok, %{video: %{room: "r9"}}} =
               TokenVerifier.verify(TokenVerifier.new("devkey", "secret"), jwt)
    end

    test "a callback without identity is a server error" do
      assert token_request(%{"room_name" => "r"}, fn _, _ -> {:ok, name: "x"} end).status == 500
    end

    test "room_join_token requires a room" do
      assert {:error, :room_required} = Livekitex.room_join_token("a", "")
    end
  end

  describe "client and transport" do
    test "list_rooms accepts call options" do
      stub_response(%LK.ListRoomsResponse{})
      assert {:ok, []} = RoomService.list_rooms(client(), timeout: 5_000)
    end

    test "unknown options are rejected instead of ignored" do
      assert_raise ArgumentError, ~r/tiemout/, fn ->
        RoomService.delete_room(client(), "r", tiemout: 1)
      end
    end

    test "custom headers do not replace auth headers" do
      stub_response(%LK.ListRoomsResponse{})

      client = client(req_options: [plug: {Req.Test, stub_name()}, headers: [{"x-trace", "1"}]])
      assert {:ok, _} = RoomService.list_rooms(client)

      assert_received {:twirp, info}
      assert info.headers["x-trace"] == "1"
      assert info.claims["video"] == %{"roomList" => true}
    end

    test "non-string error metadata does not crash" do
      stub_response(
        {:twirp_error, 400, "invalid_argument", "bad", %{"detail" => %{"a" => 1}, "n" => 3}}
      )

      assert {:error, %Error{meta: %{"detail" => detail, "n" => "3"}}} =
               RoomService.list_rooms(client())

      assert detail =~ "a"
    end

    test "unknown string keys raise KeyError" do
      assert_raise KeyError, fn ->
        Livekitex.Twirp.build(LK.ListRoomsRequest, %{"definitely_not_a_field_xyz" => 1})
      end
    end

    test "url is required" do
      Config.put(:url, nil)
      Config.put(:host, nil)
      Application.delete_env(:livekitex, :url)

      try do
        assert_raise ArgumentError, ~r/url is required/, fn -> Client.new() end
      after
        Application.put_env(:livekitex, :url, "http://localhost:7880")
      end
    end

    test "dial timeout covers ringing for WhatsApp and SIP" do
      assert Service.dial_timeout([], wait_until_answered: true, ringing_timeout: 20) == [
               timeout: 30_000
             ]

      assert Service.dial_timeout([], %LK.AcceptWhatsAppCallRequest{wait_until_answered: true}) ==
               [timeout: 40_000]

      assert Service.dial_timeout([timeout: 1], wait_until_answered: true) == [timeout: 1]
      assert Service.dial_timeout([], []) == []
    end
  end

  describe "verification" do
    @verifier TokenVerifier.new("devkey", "secret")

    defp sign(claims) do
      claims = Map.merge(%{"iss" => "devkey", "exp" => System.os_time(:second) + 60}, claims)
      {:ok, jwt, _} = Joken.encode_and_sign(claims, Joken.Signer.create("HS256", "secret"))
      jwt
    end

    test "verify_permissions compares lists and applies LiveKit defaults" do
      jwt = sign(%{"video" => %{"roomJoin" => true, "canPublishSources" => ["camera"]}})

      assert {:ok, _} =
               TokenVerifier.verify_permissions(@verifier, jwt,
                 can_publish: true,
                 can_subscribe: true
               )

      assert {:ok, _} =
               TokenVerifier.verify_permissions(@verifier, jwt, can_publish_sources: ["CAMERA"])

      assert {:error, {:missing_permissions, _}} =
               TokenVerifier.verify_permissions(@verifier, jwt,
                 can_publish_sources: ["camera", "screen_share"]
               )

      assert {:error, {:missing_permissions, _}} =
               TokenVerifier.verify_permissions(@verifier, sign(%{}),
                 can_publish_sources: ["camera"]
               )

      assert {:ok, _} = TokenVerifier.verify_permissions(@verifier, jwt, hidden: false)
    end

    test "malformed grant claims are invalid tokens, not crashes" do
      assert {:error, :invalid_token} =
               TokenVerifier.verify(@verifier, sign(%{"video" => "nope"}))

      assert {:error, :invalid_token} =
               TokenVerifier.verify(@verifier, sign(%{"roomConfig" => [1]}))
    end

    test "webhook keys may be a keyword-ish list of pairs" do
      body = ~s({"event":"room_started"})
      auth = sign_webhook(body)
      assert {:ok, _} = Webhook.receive_event(body, auth, keys: [{"devkey", "secret"}])
    end
  end
end

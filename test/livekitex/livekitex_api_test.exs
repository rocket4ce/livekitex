defmodule Livekitex.ApiTest do
  use ExUnit.Case, async: false

  alias Livekitex.{AccessToken, TokenVerifier}

  setup do
    # Ensure clean runtime config and set required env for Config.get()
    Livekitex.Config.reset()

    Application.put_env(:livekitex, :environment, :dev)

    System.put_env("LIVEKIT_API_KEY", "test_key")
    System.put_env("LIVEKIT_API_SECRET", "test_secret")
    # Set a plain host (without port) to avoid ambiguity in downstream clients
    System.put_env("LIVEKIT_HOST", "example.com")

    on_exit(fn ->
      Application.delete_env(:livekitex, :environment)
      System.delete_env("LIVEKIT_API_KEY")
      System.delete_env("LIVEKIT_API_SECRET")
      System.delete_env("LIVEKIT_HOST")
      Livekitex.Config.reset()
    end)

    :ok
  end

  describe "service constructors" do
    test "egress_service/0 returns a configured client" do
      client = Livekitex.egress_service()
      assert %Livekitex.EgressService{} = client
      assert client.api_key == "test_key"
      assert client.api_secret == "test_secret"
      assert client.host == "example.com"
      assert is_integer(client.port)
    end

    test "room_service/0 returns a configured client" do
      client = Livekitex.room_service()
      assert %Livekitex.RoomService{} = client
      assert client.api_key == "test_key"
      assert client.api_secret == "test_secret"
      assert client.host == "example.com"
      assert is_integer(client.port)
    end
  end

  describe "access token helpers" do
    test "access_token/2 builds a token struct with options" do
      token = Livekitex.access_token("user123", ttl: 1200, name: "Tester", metadata: "m")

      assert %AccessToken{} = token
      assert token.identity == "user123"
      assert token.ttl == 1200
      assert token.grants.name == "Tester"
      assert token.grants.metadata == "m"
    end

    test "room_join_token/3 issues a JWT with requested permissions" do
      {:ok, jwt} =
        Livekitex.room_join_token("userA", "room-1",
          can_publish: false,
          can_subscribe: true,
          can_publish_data: false,
          hidden: true,
          recorder: false
        )

      verifier = TokenVerifier.new("test_key", "test_secret")
      {:ok, claims} = TokenVerifier.verify(verifier, jwt)

      assert claims.identity == "userA"
      assert claims.video.room == "room-1"
      assert claims.video.can_publish == false
      assert claims.video.can_subscribe == true
      assert claims.video.can_publish_data == false
      assert claims.video.hidden == true
      assert claims.video.recorder == false
    end

    test "admin_token/1 issues a JWT with admin permissions (room-scoped)" do
      {:ok, jwt} = Livekitex.admin_token(room: "adm-room")

      verifier = TokenVerifier.new("test_key", "test_secret")
      {:ok, claims} = TokenVerifier.verify(verifier, jwt)

      assert claims.identity == "admin"
      assert claims.video.room_admin == true
      assert claims.video.room_list == true
      assert claims.video.room_create == true
      assert claims.video.room_record == true
      assert claims.video.room == "adm-room"
    end
  end

  describe "webhook validation passthrough" do
    test "validate_webhook/3 validates and parses event" do
      # Create a simple valid token using the same secret we configured
      {:ok, token, _} =
        Livekitex.AccessToken.create("webhook", "test_secret", identity: "wh-user")
        |> Livekitex.AccessToken.set_video_grant(%Livekitex.Grants.VideoGrant{room_admin: true})
        |> Livekitex.AccessToken.to_jwt()

      body = ~s({"event":"room_started","id":"w1"})
      auth = "Bearer #{token}"

      assert {:ok, event} = Livekitex.validate_webhook(body, auth)
      assert event.event == "room_started"
      assert event.id == "w1"
    end
  end

  describe "lifecycle and config" do
    test "start/0 and stop/0 attach and detach telemetry" do
      assert :ok = Livekitex.start()
      assert :ok = Livekitex.stop()
    end

    test "configure/2 updates runtime configuration" do
      assert :ok = Livekitex.configure(:host, "override.example")
      # Verify through Config.get/2
      assert Livekitex.Config.get(:host) == "override.example"
    end
  end
end

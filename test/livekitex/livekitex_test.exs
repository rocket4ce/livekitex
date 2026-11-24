defmodule LivekitexTest do
  @moduledoc "Covers the top-level facade: the functions most applications call."
  use ExUnit.Case, async: false

  import Livekitex.TestHelpers

  alias Livekitex.{AccessToken, Config, TokenVerifier}

  doctest Livekitex

  @verifier TokenVerifier.new("devkey", "secret")

  setup do
    on_exit(&Config.reset/0)
  end

  describe "client/1" do
    test "builds a client from the application config" do
      assert %Livekitex.Client{base_url: "http://localhost:7880", api_key: "devkey"} =
               Livekitex.client()
    end

    test "options win over the config" do
      assert %Livekitex.Client{base_url: "https://other.example", timeout: 500} =
               Livekitex.client(url: "wss://other.example", timeout: 500)
    end
  end

  describe "access_token/2" do
    test "uses the configured credentials and the given identity" do
      token = Livekitex.access_token("alice", name: "Alice", ttl: 60)

      assert %AccessToken{api_key: "devkey", identity: "alice", ttl: 60} = token
      assert token.grants.name == "Alice"
    end
  end

  describe "room_join_token/3" do
    test "signs a token scoped to one room" do
      assert {:ok, jwt} = Livekitex.room_join_token("alice", "standup")
      assert {:ok, grant} = TokenVerifier.verify(@verifier, jwt)

      assert grant.identity == "alice"
      assert grant.video.room_join == true
      assert grant.video.room == "standup"
    end

    test "extra options are video grant fields" do
      assert {:ok, jwt} =
               Livekitex.room_join_token("alice", "standup",
                 name: "Alice",
                 can_publish: false,
                 can_publish_sources: ["CAMERA"]
               )

      assert {:ok, grant} = TokenVerifier.verify(@verifier, jwt)
      assert grant.name == "Alice"
      assert grant.video.can_publish == false
      assert grant.video.can_publish_sources == ["camera"]
    end

    test "room_config dispatches an agent when the room is created" do
      assert {:ok, jwt} =
               Livekitex.room_join_token("alice", "standup",
                 room_config: [agents: [[agent_name: "notetaker"]]]
               )

      assert {:ok, grant} = TokenVerifier.verify(@verifier, jwt)
      assert [%{agent_name: "notetaker"}] = grant.room_config.agents
    end

    test "refuses a token that would be valid for every room" do
      assert {:error, :room_required} = Livekitex.room_join_token("alice", nil)
      assert {:error, :room_required} = Livekitex.room_join_token("alice", "")
    end

    test "a join token needs an identity" do
      assert {:error, :identity_required} = Livekitex.room_join_token("", "standup")
    end
  end

  describe "admin_token/1" do
    test "grants room administration without a room join" do
      assert {:ok, jwt} = Livekitex.admin_token(identity: "ops")
      assert {:ok, grant} = TokenVerifier.verify(@verifier, jwt)

      assert grant.video.room_create == true
      assert grant.video.room_list == true
      assert grant.video.room_admin == true
      assert grant.video.room_record == true
      assert grant.video.room_join == nil
    end

    test "can be scoped to a single room" do
      assert {:ok, jwt} = Livekitex.admin_token(room: "standup")
      assert {:ok, grant} = TokenVerifier.verify(@verifier, jwt)
      assert grant.video.room == "standup"
    end
  end

  describe "receive_webhook/3" do
    test "verifies and decodes an event" do
      %{"body" => body} =
        "test/fixtures/webhook_room_started.json" |> File.read!() |> Jason.decode!()

      assert {:ok, event} = Livekitex.receive_webhook(body, sign_webhook(body))
      assert event.event == "room_started"
      assert event.room.name == "smoke-room"
    end

    test "rejects a body that does not match the signed hash" do
      body = ~s({"event":"room_started"})
      auth = sign_webhook(body)

      assert {:error, :hash_mismatch} = Livekitex.receive_webhook(~s({"event":"other"}), auth)
    end
  end

  describe "config/0, configure/2 and version/0" do
    test "runtime overrides win and can be reset" do
      assert Livekitex.config().timeout == 10_000

      assert :ok = Livekitex.configure(:timeout, 1234)
      assert Livekitex.config().timeout == 1234

      Config.reset()
      assert Livekitex.config().timeout == 10_000
    end

    test "version/0 reports the library version" do
      assert Livekitex.version() == Mix.Project.config()[:version]
    end
  end
end

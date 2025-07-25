defmodule Livekitex.AccessTokenTest do
  use ExUnit.Case, async: true

  alias Livekitex.AccessToken
  alias Livekitex.Grants.{VideoGrant, SipGrant}

  describe "create/3" do
    test "creates a new AccessToken with basic options" do
      token = AccessToken.create("api_key", "api_secret", identity: "user", name: "User Name")

      assert %AccessToken{} = token
      assert token.api_key == "api_key"
      assert token.api_secret == "api_secret"
      assert token.identity == "user"
      # default TTL
      assert token.ttl == 600
      assert token.grants.name == "User Name"
    end

    test "creates AccessToken with custom TTL" do
      token = AccessToken.create("api_key", "api_secret", identity: "user", ttl: 1200)

      assert token.ttl == 1200
    end

    test "creates AccessToken with metadata and attributes" do
      token =
        AccessToken.create("api_key", "api_secret",
          identity: "user",
          metadata: "test-metadata",
          attributes: %{"role" => "admin"}
        )

      assert token.grants.metadata == "test-metadata"
      assert token.grants.attributes == %{"role" => "admin"}
    end
  end

  describe "set_video_grant/2" do
    test "sets video grant from VideoGrant struct" do
      token = AccessToken.create("api_key", "api_secret", identity: "user")
      video_grant = VideoGrant.new(room_join: true, can_publish: true)

      updated_token = AccessToken.set_video_grant(token, video_grant)

      assert updated_token.grants.video.room_join == true
      assert updated_token.grants.video.can_publish == true
    end

    test "sets video grant from keyword list" do
      token = AccessToken.create("api_key", "api_secret", identity: "user")

      updated_token = AccessToken.set_video_grant(token, room_join: true, can_publish: false)

      assert updated_token.grants.video.room_join == true
      assert updated_token.grants.video.can_publish == false
    end
  end

  describe "set_sip_grant/2" do
    test "sets SIP grant from SipGrant struct" do
      token = AccessToken.create("api_key", "api_secret", identity: "user")
      sip_grant = SipGrant.new(admin: true, call: false)

      updated_token = AccessToken.set_sip_grant(token, sip_grant)

      assert updated_token.grants.sip.admin == true
      assert updated_token.grants.sip.call == false
    end

    test "sets SIP grant from keyword list" do
      token = AccessToken.create("api_key", "api_secret", identity: "user")

      updated_token = AccessToken.set_sip_grant(token, admin: true, call: true)

      assert updated_token.grants.sip.admin == true
      assert updated_token.grants.sip.call == true
    end
  end

  describe "metadata and attribute setters" do
    test "set_metadata/2 updates metadata" do
      token = AccessToken.create("api_key", "api_secret", identity: "user")
      updated_token = AccessToken.set_metadata(token, "new-metadata")

      assert updated_token.grants.metadata == "new-metadata"
    end

    test "set_attributes/2 updates attributes" do
      token = AccessToken.create("api_key", "api_secret", identity: "user")
      updated_token = AccessToken.set_attributes(token, %{"role" => "moderator"})

      assert updated_token.grants.attributes == %{"role" => "moderator"}
    end

    test "set_name/2 updates name" do
      token = AccessToken.create("api_key", "api_secret", identity: "user")
      updated_token = AccessToken.set_name(token, "New Name")

      assert updated_token.grants.name == "New Name"
    end

    test "set_sha256/2 updates SHA256" do
      token = AccessToken.create("api_key", "api_secret", identity: "user")
      updated_token = AccessToken.set_sha256(token, "abc123")

      assert updated_token.grants.sha256 == "abc123"
    end

    test "set_room_config/2 updates room config" do
      token = AccessToken.create("api_key", "api_secret", identity: "user")
      config = %{"maxParticipants" => 10}
      updated_token = AccessToken.set_room_config(token, config)

      assert updated_token.grants.room_config == config
    end

    test "set_room_preset/2 updates room preset" do
      token = AccessToken.create("api_key", "api_secret", identity: "user")
      updated_token = AccessToken.set_room_preset(token, "group_call")

      assert updated_token.grants.room_preset == "group_call"
    end
  end

  describe "to_jwt/1" do
    test "generates a valid JWT token with video grant" do
      token = AccessToken.create("devkey", "secret", identity: "user", name: "User Name")
      video_grant = VideoGrant.new(room_join: true, can_publish: true)
      token = AccessToken.set_video_grant(token, video_grant)

      {:ok, jwt, _claims} = AccessToken.to_jwt(token)

      assert is_binary(jwt)
    end

    test "generates a valid JWT token with SIP grant" do
      token = AccessToken.create("devkey", "secret", identity: "user")
      sip_grant = SipGrant.new(admin: true)
      token = AccessToken.set_sip_grant(token, sip_grant)

      {:ok, jwt, _claims} = AccessToken.to_jwt(token)

      assert is_binary(jwt)
    end

    test "fails when no grants are provided" do
      token = AccessToken.create("devkey", "secret", identity: "user")

      {:error, reason} = AccessToken.to_jwt(token)

      assert reason == "VideoGrant or SipGrant is required"
    end

    test "includes correct claims in JWT" do
      token =
        AccessToken.create("devkey", "secret",
          identity: "user123",
          name: "Test User",
          metadata: "test-metadata"
        )

      video_grant = VideoGrant.new(room_join: true, can_publish: false, room: "test-room")
      token = AccessToken.set_video_grant(token, video_grant)

      {:ok, _jwt, claims} = AccessToken.to_jwt(token)

      assert claims["sub"] == "user123"
      assert claims["iss"] == "devkey"
      assert claims["name"] == "Test User"
      assert claims["metadata"] == "test-metadata"
      assert claims["video"]["roomJoin"] == true
      assert claims["video"]["canPublish"] == false
      assert claims["video"]["room"] == "test-room"
      assert is_integer(claims["exp"])
      assert is_integer(claims["iat"])
      assert is_integer(claims["nbf"])
    end

    test "filters out nil values from claims" do
      token = AccessToken.create("devkey", "secret", identity: "user123")
      video_grant = VideoGrant.new(room_join: true, can_publish: nil)
      token = AccessToken.set_video_grant(token, video_grant)

      {:ok, _jwt, claims} = AccessToken.to_jwt(token)

      assert claims["video"]["roomJoin"] == true
      refute Map.has_key?(claims["video"], "canPublish")
      refute Map.has_key?(claims, "name")
      refute Map.has_key?(claims, "metadata")
    end
  end

  describe "to_jwt!/1" do
    test "returns JWT string on success" do
      token = AccessToken.create("devkey", "secret", identity: "user")
      video_grant = VideoGrant.new(room_join: true)
      token = AccessToken.set_video_grant(token, video_grant)

      jwt = AccessToken.to_jwt!(token)

      assert is_binary(jwt)
    end

    test "raises on error" do
      token = AccessToken.create("devkey", "secret", identity: "user")

      assert_raise RuntimeError, ~r/Failed to generate JWT/, fn ->
        AccessToken.to_jwt!(token)
      end
    end
  end
end

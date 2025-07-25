defmodule Livekitex.GrantsTest do
  use ExUnit.Case, async: true

  alias Livekitex.Grants.{VideoGrant, SipGrant, ClaimGrant}

  describe "VideoGrant" do
    test "creates a new VideoGrant with default values" do
      grant = VideoGrant.new()
      assert %VideoGrant{} = grant
      assert is_nil(grant.room_join)
      assert is_nil(grant.can_publish)
    end

    test "creates a VideoGrant with specified permissions" do
      grant = VideoGrant.new(room_join: true, can_publish: true, room: "test-room")

      assert grant.room_join == true
      assert grant.can_publish == true
      assert grant.room == "test-room"
    end

    test "creates VideoGrant from map with camelCase keys" do
      map = %{
        "roomJoin" => true,
        "canPublish" => false,
        "roomAdmin" => true,
        "room" => "admin-room"
      }

      grant = VideoGrant.from_map(map)

      assert grant.room_join == true
      assert grant.can_publish == false
      assert grant.room_admin == true
      assert grant.room == "admin-room"
    end

    test "creates VideoGrant from map with snake_case keys" do
      map = %{
        room_join: true,
        can_publish: false,
        room_admin: true,
        room: "admin-room"
      }

      grant = VideoGrant.from_map(map)

      assert grant.room_join == true
      assert grant.can_publish == false
      assert grant.room_admin == true
      assert grant.room == "admin-room"
    end

    test "returns nil when creating from nil map" do
      assert VideoGrant.from_map(nil) == nil
    end

    test "converts VideoGrant to map with camelCase keys" do
      grant =
        VideoGrant.new(
          room_join: true,
          can_publish: false,
          room_admin: true,
          room: "test-room",
          can_update_own_metadata: true
        )

      map = VideoGrant.to_map(grant)

      assert map["roomJoin"] == true
      assert map["canPublish"] == false
      assert map["roomAdmin"] == true
      assert map["room"] == "test-room"
      assert map["canUpdateOwnMetadata"] == true
    end

    test "filters out nil values when converting to map" do
      grant = VideoGrant.new(room_join: true, can_publish: nil)
      map = VideoGrant.to_map(grant)

      assert Map.has_key?(map, "roomJoin")
      refute Map.has_key?(map, "canPublish")
    end
  end

  describe "SipGrant" do
    test "creates a new SipGrant with default values" do
      grant = SipGrant.new()
      assert %SipGrant{} = grant
      assert is_nil(grant.admin)
      assert is_nil(grant.call)
    end

    test "creates a SipGrant with specified permissions" do
      grant = SipGrant.new(admin: true, call: false)

      assert grant.admin == true
      assert grant.call == false
    end

    test "creates SipGrant from map" do
      map = %{"admin" => true, "call" => false}
      grant = SipGrant.from_map(map)

      assert grant.admin == true
      assert grant.call == false
    end

    test "returns nil when creating from nil map" do
      assert SipGrant.from_map(nil) == nil
    end

    test "converts SipGrant to map" do
      grant = SipGrant.new(admin: true, call: false)
      map = SipGrant.to_map(grant)

      assert map["admin"] == true
      assert map["call"] == false
    end

    test "filters out nil values when converting to map" do
      grant = SipGrant.new(admin: true, call: nil)
      map = SipGrant.to_map(grant)

      assert Map.has_key?(map, "admin")
      refute Map.has_key?(map, "call")
    end
  end

  describe "ClaimGrant" do
    test "creates ClaimGrant from JWT claims" do
      claims = %{
        "sub" => "user123",
        "name" => "Test User",
        "metadata" => "test-metadata",
        "video" => %{
          "roomJoin" => true,
          "canPublish" => true
        },
        "sip" => %{
          "admin" => true
        }
      }

      grant = ClaimGrant.from_claims(claims)

      assert grant.identity == "user123"
      assert grant.name == "Test User"
      assert grant.metadata == "test-metadata"
      assert grant.video.room_join == true
      assert grant.video.can_publish == true
      assert grant.sip.admin == true
    end

    test "returns nil when creating from nil claims" do
      assert ClaimGrant.from_claims(nil) == nil
    end

    test "handles missing video and sip grants" do
      claims = %{
        "sub" => "user123",
        "name" => "Test User"
      }

      grant = ClaimGrant.from_claims(claims)

      assert grant.identity == "user123"
      assert grant.name == "Test User"
      assert is_nil(grant.video)
      assert is_nil(grant.sip)
    end

    test "converts ClaimGrant to claims map" do
      video_grant = VideoGrant.new(room_join: true, can_publish: false)
      sip_grant = SipGrant.new(admin: true)

      grant = %ClaimGrant{
        name: "Test User",
        metadata: "test-metadata",
        video: video_grant,
        sip: sip_grant,
        attributes: %{"role" => "moderator"}
      }

      claims = ClaimGrant.to_claims(grant)

      assert claims["name"] == "Test User"
      assert claims["metadata"] == "test-metadata"
      assert claims["attributes"]["role"] == "moderator"
      assert claims["video"]["roomJoin"] == true
      assert claims["video"]["canPublish"] == false
      assert claims["sip"]["admin"] == true
    end

    test "filters out nil values when converting to claims" do
      grant = %ClaimGrant{
        name: "Test User",
        metadata: nil,
        video: nil,
        sip: nil
      }

      claims = ClaimGrant.to_claims(grant)

      assert Map.has_key?(claims, "name")
      refute Map.has_key?(claims, "metadata")
      refute Map.has_key?(claims, "video")
      refute Map.has_key?(claims, "sip")
    end
  end
end

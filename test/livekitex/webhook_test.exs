defmodule Livekitex.WebhookTest do
  use ExUnit.Case, async: true
  alias Livekitex.{Webhook, AccessToken, Grants}

  @api_secret "test_secret"
  @valid_webhook_body """
  {
    "event": "room_started",
    "id": "webhook_123",
    "createdAt": 1640995200,
    "room": {
      "sid": "room_123",
      "name": "test-room",
      "numParticipants": 2,
      "activeRecording": false
    },
    "participant": {
      "sid": "participant_123",
      "identity": "user123",
      "state": "ACTIVE",
      "joinedAt": 1640995100,
      "name": "Test User"
    }
  }
  """

  describe "validate_webhook/3" do
    test "validates webhook with valid token" do
      token = create_valid_token()
      auth_header = "Bearer #{token}"

      assert {:ok, event} =
               Webhook.validate_webhook(@valid_webhook_body, auth_header, @api_secret)

      assert event.event == "room_started"
      assert event.id == "webhook_123"
      assert event.room.name == "test-room"
      assert event.participant.identity == "user123"
    end

    test "rejects webhook with invalid token" do
      auth_header = "Bearer invalid_token"

      assert {:error, _reason} =
               Webhook.validate_webhook(@valid_webhook_body, auth_header, @api_secret)
    end

    test "rejects webhook with malformed auth header" do
      assert {:error, :invalid_auth_header} =
               Webhook.validate_webhook(@valid_webhook_body, "invalid", @api_secret)
    end

    test "rejects webhook with invalid JSON" do
      token = create_valid_token()
      auth_header = "Bearer #{token}"
      invalid_json = "{ invalid json"

      assert {:error, :invalid_json} =
               Webhook.validate_webhook(invalid_json, auth_header, @api_secret)
    end
  end

  describe "parse_webhook_event/1" do
    test "parses valid webhook event" do
      assert {:ok, event} = Webhook.parse_webhook_event(@valid_webhook_body)

      assert event.event == "room_started"
      assert event.id == "webhook_123"
      assert event.created_at == 1_640_995_200
      assert event.num_dropped == 0

      # Room data
      assert event.room.sid == "room_123"
      assert event.room.name == "test-room"
      assert event.room.num_participants == 2
      assert event.room.active_recording == false

      # Participant data
      assert event.participant.sid == "participant_123"
      assert event.participant.identity == "user123"
      assert event.participant.state == "ACTIVE"
      assert event.participant.joined_at == 1_640_995_100
      assert event.participant.name == "Test User"
    end

    test "handles minimal webhook event" do
      minimal_body = """
      {
        "event": "participant_joined",
        "id": "webhook_456"
      }
      """

      assert {:ok, event} = Webhook.parse_webhook_event(minimal_body)
      assert event.event == "participant_joined"
      assert event.id == "webhook_456"
      assert is_nil(event.room)
      assert is_nil(event.participant)
    end

    test "rejects invalid JSON" do
      assert {:error, :invalid_json} = Webhook.parse_webhook_event("{ invalid")
    end
  end

  describe "create_plug/2" do
    test "creates a plug function" do
      plug_fun = Webhook.create_plug(@api_secret)
      assert is_function(plug_fun, 2)
    end
  end

  # Helper functions

  defp create_valid_token do
    grant = %Grants.VideoGrant{room_admin: true}

    {:ok, token, _claims} =
      AccessToken.create("webhook", @api_secret, identity: "test")
      |> AccessToken.set_video_grant(grant)
      |> AccessToken.to_jwt()

    token
  end
end

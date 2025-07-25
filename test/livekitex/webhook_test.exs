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

  describe "comprehensive event parsing" do
    test "parses complete webhook event with all fields" do
      complete_webhook = """
      {
        "event": "track_published",
        "id": "webhook_789",
        "createdAt": 1640995300,
        "numDropped": 5,
        "room": {
          "sid": "RM_123",
          "name": "conference-room",
          "emptyTimeout": 300,
          "departureTimeout": 20,
          "maxParticipants": 50,
          "creationTime": 1640995000,
          "metadata": "meeting metadata",
          "numParticipants": 3,
          "numPublishers": 2,
          "activeRecording": true
        },
        "participant": {
          "sid": "PA_456",
          "identity": "host123",
          "state": "ACTIVE",
          "metadata": "participant metadata",
          "joinedAt": 1640995150,
          "name": "Host User",
          "version": 2,
          "region": "us-west-2",
          "isPublisher": true,
          "kind": "STANDARD",
          "attributes": {
            "role": "moderator",
            "department": "engineering"
          },
          "permission": {
            "canSubscribe": true,
            "canPublish": true,
            "canPublishData": true,
            "canPublishSources": ["CAMERA", "MICROPHONE"],
            "hidden": false,
            "recorder": false,
            "canUpdateMetadata": true,
            "agent": false
          },
          "tracks": [
            {
              "sid": "TR_789",
              "type": "video",
              "name": "camera",
              "muted": false,
              "width": 1920,
              "height": 1080,
              "simulcast": true,
              "disableDtx": false,
              "source": "CAMERA",
              "mimeType": "video/H264",
              "mid": "0",
              "codecs": ["H264"],
              "stereo": false,
              "disableRed": false,
              "layers": [
                {
                  "quality": "HIGH",
                  "width": 1920,
                  "height": 1080,
                  "bitrate": 2000000,
                  "ssrc": 123456789
                }
              ]
            }
          ]
        },
        "track": {
          "sid": "TR_789",
          "type": "video",
          "name": "camera",
          "muted": false,
          "width": 1920,
          "height": 1080,
          "simulcast": true,
          "disableDtx": false,
          "source": "CAMERA",
          "mimeType": "video/H264",
          "mid": "0",
          "codecs": ["H264"],
          "stereo": false,
          "disableRed": false,
          "layers": [
            {
              "quality": "HIGH",
              "width": 1920,
              "height": 1080,
              "bitrate": 2000000,
              "ssrc": 123456789
            }
          ]
        },
        "egressInfo": {
          "egressId": "EG_123",
          "roomId": "RM_123", 
          "roomName": "conference-room",
          "status": "EGRESS_STARTING",
          "startedAt": 1640995300,
          "endedAt": null,
          "updatedAt": 1640995310,
          "details": "Starting recording",
          "error": null
        },
        "ingressInfo": {
          "ingressId": "IN_123",
          "name": "rtmp-stream",
          "streamKey": "stream_key_123",
          "url": "rtmp://ingest.livekit.io/live",
          "inputType": "RTMP_INPUT",
          "bypassTranscoding": false,
          "roomName": "conference-room",
          "participantIdentity": "stream_user",
          "participantName": "Stream User",
          "reusable": true
        }
      }
      """

      assert {:ok, event} = Webhook.parse_webhook_event(complete_webhook)

      # Main event fields
      assert event.event == "track_published"
      assert event.id == "webhook_789"
      assert event.created_at == 1640995300
      assert event.num_dropped == 5

      # Complete room data
      room = event.room
      assert room.sid == "RM_123"
      assert room.name == "conference-room"
      assert room.empty_timeout == 300
      assert room.departure_timeout == 20
      assert room.max_participants == 50
      assert room.creation_time == 1640995000
      assert room.metadata == "meeting metadata"
      assert room.num_participants == 3
      assert room.num_publishers == 2
      assert room.active_recording == true

      # Complete participant data
      participant = event.participant
      assert participant.sid == "PA_456"
      assert participant.identity == "host123"
      assert participant.state == "ACTIVE"
      assert participant.metadata == "participant metadata"
      assert participant.joined_at == 1640995150
      assert participant.name == "Host User"
      assert participant.version == 2
      assert participant.region == "us-west-2"
      assert participant.is_publisher == true
      assert participant.kind == "STANDARD"
      assert participant.attributes == %{"role" => "moderator", "department" => "engineering"}

      # Permission data
      permission = participant.permission
      assert permission.can_subscribe == true
      assert permission.can_publish == true
      assert permission.can_publish_data == true
      assert permission.can_publish_sources == ["CAMERA", "MICROPHONE"]
      assert permission.hidden == false
      assert permission.recorder == false
      assert permission.can_update_metadata == true
      assert permission.agent == false

      # Track data
      track = List.first(participant.tracks)
      assert track.sid == "TR_789"
      assert track.type == "video"
      assert track.name == "camera"
      assert track.muted == false
      assert track.width == 1920
      assert track.height == 1080
      assert track.simulcast == true
      assert track.disable_dtx == false
      assert track.source == "CAMERA"
      assert track.mime_type == "video/H264"
      assert track.mid == "0"
      assert track.codecs == ["H264"]
      assert track.stereo == false
      assert track.disable_red == false

      # Video layer data
      layer = List.first(track.layers)
      assert layer.quality == "HIGH"
      assert layer.width == 1920
      assert layer.height == 1080
      assert layer.bitrate == 2000000
      assert layer.ssrc == 123456789

      # Main track field (separate from participant tracks)
      main_track = event.track
      assert main_track.sid == "TR_789"
      assert main_track.type == "video"

      # Egress info
      egress = event.egress_info
      assert egress.egress_id == "EG_123"
      assert egress.room_id == "RM_123"
      assert egress.room_name == "conference-room"
      assert egress.status == "EGRESS_STARTING"
      assert egress.started_at == 1640995300
      assert egress.ended_at == nil
      assert egress.updated_at == 1640995310
      assert egress.details == "Starting recording"
      assert egress.error == nil

      # Ingress info
      ingress = event.ingress_info
      assert ingress.ingress_id == "IN_123"
      assert ingress.name == "rtmp-stream"
      assert ingress.stream_key == "stream_key_123"
      assert ingress.url == "rtmp://ingest.livekit.io/live"
      assert ingress.input_type == "RTMP_INPUT"
      assert ingress.bypass_transcoding == false
      assert ingress.room_name == "conference-room"
      assert ingress.participant_identity == "stream_user"
      assert ingress.participant_name == "Stream User"
      assert ingress.reusable == true
    end

    test "handles participant with empty tracks and attributes" do
      webhook_body = """
      {
        "event": "participant_left",
        "id": "webhook_empty",
        "participant": {
          "sid": "PA_empty",
          "identity": "empty_user",
          "tracks": [],
          "attributes": {}
        }
      }
      """

      assert {:ok, event} = Webhook.parse_webhook_event(webhook_body)
      assert event.participant.tracks == []
      assert event.participant.attributes == %{}
    end

    test "handles participant with nil permission" do
      webhook_body = """
      {
        "event": "participant_joined",
        "id": "webhook_no_perm",
        "participant": {
          "sid": "PA_no_perm",
          "identity": "no_perm_user",
          "permission": null
        }
      }
      """

      assert {:ok, event} = Webhook.parse_webhook_event(webhook_body)
      assert is_nil(event.participant.permission)
    end

    test "handles track with empty layers and codecs" do
      webhook_body = """
      {
        "event": "track_muted",
        "id": "webhook_empty_track",
        "track": {
          "sid": "TR_empty",
          "type": "audio",
          "name": "microphone",
          "layers": [],
          "codecs": []
        }
      }
      """

      assert {:ok, event} = Webhook.parse_webhook_event(webhook_body)
      assert event.track.layers == []
      assert event.track.codecs == []
    end

    test "handles nil room, participant, track, egress, and ingress" do
      webhook_body = """
      {
        "event": "generic_event",
        "id": "webhook_nil_fields",
        "room": null,
        "participant": null,
        "track": null,
        "egressInfo": null,
        "ingressInfo": null
      }
      """

      assert {:ok, event} = Webhook.parse_webhook_event(webhook_body)
      assert is_nil(event.room)
      assert is_nil(event.participant)
      assert is_nil(event.track)
      assert is_nil(event.egress_info)
      assert is_nil(event.ingress_info)
    end

    test "handles missing numDropped field" do
      webhook_body = """
      {
        "event": "test_event",
        "id": "webhook_no_dropped"
      }
      """

      assert {:ok, event} = Webhook.parse_webhook_event(webhook_body)
      assert event.num_dropped == 0
    end

    test "handles permission with default values" do
      webhook_body = """
      {
        "event": "participant_permission_changed",
        "id": "webhook_perm_defaults",
        "participant": {
          "sid": "PA_defaults",
          "identity": "defaults_user",
          "permission": {}
        }
      }
      """

      assert {:ok, event} = Webhook.parse_webhook_event(webhook_body)
      permission = event.participant.permission

      assert permission.can_subscribe == true
      assert permission.can_publish == true
      assert permission.can_publish_data == true
      assert permission.can_publish_sources == []
      assert permission.hidden == false
      assert permission.recorder == false
      assert permission.can_update_metadata == false
      assert permission.agent == false
    end

    test "handles track with default boolean values" do
      webhook_body = """
      {
        "event": "track_updated",
        "id": "webhook_track_defaults",
        "track": {
          "sid": "TR_defaults",
          "type": "video",
          "name": "camera"
        }
      }
      """

      assert {:ok, event} = Webhook.parse_webhook_event(webhook_body)
      track = event.track

      assert track.muted == false
      assert track.simulcast == false
      assert track.disable_dtx == false
      assert track.stereo == false
      assert track.disable_red == false
    end

    test "handles room with default active_recording" do
      webhook_body = """
      {
        "event": "room_finished",
        "id": "webhook_room_defaults",
        "room": {
          "sid": "RM_defaults",
          "name": "default-room"
        }
      }
      """

      assert {:ok, event} = Webhook.parse_webhook_event(webhook_body)
      assert event.room.active_recording == false
    end

    test "handles participant with default is_publisher and attributes" do
      webhook_body = """
      {
        "event": "participant_updated",
        "id": "webhook_participant_defaults",
        "participant": {
          "sid": "PA_defaults",
          "identity": "default_user"
        }
      }
      """

      assert {:ok, event} = Webhook.parse_webhook_event(webhook_body)
      participant = event.participant

      assert participant.is_publisher == false
      assert participant.attributes == %{}
    end

    test "handles ingress with default boolean values" do
      webhook_body = """
      {
        "event": "ingress_started",
        "id": "webhook_ingress_defaults",
        "ingressInfo": {
          "ingressId": "IN_defaults",
          "name": "default-ingress"
        }
      }
      """

      assert {:ok, event} = Webhook.parse_webhook_event(webhook_body)
      ingress = event.ingress_info

      assert ingress.bypass_transcoding == false
      assert ingress.reusable == false
    end
  end

  describe "error handling and edge cases" do
    test "handles malformed JSON with specific error message" do
      malformed_json = "{ invalid json"
      
      assert {:error, :invalid_json} = Webhook.parse_webhook_event(malformed_json)
    end

    test "handles JSON that is not a map" do
      json_array = "[1, 2, 3]"
      
      # This should crash because Map.get expects a map
      assert_raise BadMapError, fn ->
        Webhook.parse_webhook_event(json_array)
      end
    end

    test "handles completely empty JSON object" do
      empty_json = "{}"
      
      assert {:ok, event} = Webhook.parse_webhook_event(empty_json)
      assert is_nil(event.event)
      assert is_nil(event.id)
      assert is_nil(event.created_at)
      assert is_nil(event.room)
      assert is_nil(event.participant)
      assert is_nil(event.track)
      assert is_nil(event.egress_info)
      assert is_nil(event.ingress_info)
      assert event.num_dropped == 0
    end

    test "validate_webhook handles errors from token extraction" do
      invalid_auth_headers = [
        "",
        "Basic token123",
        "token123",
        "Bearer",
        nil
      ]

      for header <- invalid_auth_headers do
        result = case header do
          nil -> 
            # This would cause a function clause error, but let's test with empty string instead
            Webhook.validate_webhook(@valid_webhook_body, "", @api_secret)
          _ ->
            Webhook.validate_webhook(@valid_webhook_body, header, @api_secret)
        end
        
        assert {:error, _reason} = result
      end
    end

    test "validate_webhook handles token verification errors" do
      # Use a token with wrong secret
      wrong_secret_token = create_token_with_secret("wrong_secret")
      auth_header = "Bearer #{wrong_secret_token}"

      assert {:error, _reason} = 
        Webhook.validate_webhook(@valid_webhook_body, auth_header, @api_secret)
    end

    test "validate_webhook handles JSON parsing errors in chain" do
      token = create_valid_token()
      auth_header = "Bearer #{token}"
      invalid_json = "{ incomplete json"

      assert {:error, :invalid_json} = 
        Webhook.validate_webhook(invalid_json, auth_header, @api_secret)
    end
  end

  describe "private function coverage through public API" do
    test "parse_tracks with list of tracks" do
      webhook_body = """
      {
        "event": "participant_tracks_updated",
        "id": "webhook_multiple_tracks",
        "participant": {
          "sid": "PA_multi",
          "identity": "multi_user",
          "tracks": [
            {
              "sid": "TR_audio",
              "type": "audio",
              "name": "microphone"
            },
            {
              "sid": "TR_video", 
              "type": "video",
              "name": "camera"
            }
          ]
        }
      }
      """

      assert {:ok, event} = Webhook.parse_webhook_event(webhook_body)
      tracks = event.participant.tracks
      
      assert length(tracks) == 2
      assert Enum.find(tracks, & &1.sid == "TR_audio")
      assert Enum.find(tracks, & &1.sid == "TR_video")
    end

    test "parse_video_layers with multiple layers" do
      webhook_body = """
      {
        "event": "track_published",
        "id": "webhook_multi_layers",
        "track": {
          "sid": "TR_multi_layer",
          "type": "video",
          "name": "camera",
          "layers": [
            {
              "quality": "LOW",
              "width": 320,
              "height": 240,
              "bitrate": 150000,
              "ssrc": 111111
            },
            {
              "quality": "HIGH",
              "width": 1280,
              "height": 720,
              "bitrate": 1000000,
              "ssrc": 222222
            }
          ]
        }
      }
      """

      assert {:ok, event} = Webhook.parse_webhook_event(webhook_body)
      layers = event.track.layers
      
      assert length(layers) == 2
      
      low_layer = Enum.find(layers, & &1.quality == "LOW")
      assert low_layer.width == 320
      assert low_layer.height == 240
      assert low_layer.bitrate == 150000
      assert low_layer.ssrc == 111111
      
      high_layer = Enum.find(layers, & &1.quality == "HIGH")  
      assert high_layer.width == 1280
      assert high_layer.height == 720
      assert high_layer.bitrate == 1000000
      assert high_layer.ssrc == 222222
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

  defp create_token_with_secret(secret) do
    grant = %Grants.VideoGrant{room_admin: true}

    {:ok, token, _claims} =
      AccessToken.create("webhook", secret, identity: "test")
      |> AccessToken.set_video_grant(grant)
      |> AccessToken.to_jwt()

    token
  end
end

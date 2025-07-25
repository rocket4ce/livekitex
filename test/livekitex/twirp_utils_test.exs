defmodule Livekitex.TwirpUtilsTest do
  use ExUnit.Case, async: true

  alias Livekitex.{TwirpUtils, Room}

  describe "handle_twirp_response/1" do
    test "handles successful responses" do
      response = %{name: "test-room", sid: "RM_123"}
      assert {:ok, ^response} = TwirpUtils.handle_twirp_response({:ok, response})
    end

    test "handles Twirp errors" do
      error = %Twirp.Error{code: :not_found, msg: "Room not found"}
      result = TwirpUtils.handle_twirp_response({:error, error})
      assert {:error, {:not_found, "Room not found"}} = result
    end

    test "handles communication errors" do
      result = TwirpUtils.handle_twirp_response({:error, :econnrefused})
      assert {:error, {:twirp_error, :econnrefused}} = result
    end
  end

  describe "format_twirp_error/1" do
    test "formats unauthenticated error" do
      error = %Twirp.Error{code: :unauthenticated, msg: "Invalid credentials"}
      result = TwirpUtils.format_twirp_error(error)
      assert {:unauthenticated, "Invalid credentials"} = result
    end

    test "formats permission_denied error" do
      error = %Twirp.Error{code: :permission_denied, msg: "Access denied"}
      result = TwirpUtils.format_twirp_error(error)
      assert {:permission_denied, "Access denied"} = result
    end

    test "formats not_found error" do
      error = %Twirp.Error{code: :not_found, msg: "Resource not found"}
      result = TwirpUtils.format_twirp_error(error)
      assert {:not_found, "Resource not found"} = result
    end

    test "formats already_exists error" do
      error = %Twirp.Error{code: :already_exists, msg: "Resource exists"}
      result = TwirpUtils.format_twirp_error(error)
      assert {:already_exists, "Resource exists"} = result
    end

    test "formats invalid_argument error" do
      error = %Twirp.Error{code: :invalid_argument, msg: "Bad request"}
      result = TwirpUtils.format_twirp_error(error)
      assert {:invalid_argument, "Bad request"} = result
    end

    test "formats unavailable error" do
      error = %Twirp.Error{code: :unavailable, msg: "Service unavailable"}
      result = TwirpUtils.format_twirp_error(error)
      assert {:unavailable, "Service unavailable"} = result
    end

    test "formats deadline_exceeded error" do
      error = %Twirp.Error{code: :deadline_exceeded, msg: "Request timeout"}
      result = TwirpUtils.format_twirp_error(error)
      assert {:deadline_exceeded, "Request timeout"} = result
    end

    test "formats internal error" do
      error = %Twirp.Error{code: :internal, msg: "Internal error"}
      result = TwirpUtils.format_twirp_error(error)
      assert {:internal_error, "Internal error"} = result
    end

    test "formats unknown error codes" do
      error = %Twirp.Error{code: :unknown_code, msg: "Unknown error"}
      result = TwirpUtils.format_twirp_error(error)
      assert {:twirp_error, {:unknown_code, "Unknown error"}} = result
    end
  end

  describe "create_client/3" do
    test "creates client without token" do
      client = TwirpUtils.create_client("http://localhost:7880")
      assert %Tesla.Client{} = client
    end

    test "creates client with token" do
      client = TwirpUtils.create_client("http://localhost:7880", "test_token")
      assert %Tesla.Client{} = client
    end

    test "creates client with custom options" do
      client = TwirpUtils.create_client("http://localhost:7880", nil, timeout: 5000)
      assert %Tesla.Client{} = client
    end
  end

  describe "proto_to_room/1" do
    test "converts protobuf room to internal room struct" do
      proto_room = %Livekit.Room{
        name: "test-room",
        sid: "RM_123",
        empty_timeout: 300,
        departure_timeout: 20,
        max_participants: 10,
        creation_time: 1640995200,
        turn_password: "password123",
        enabled_codecs: [
          %Livekit.Codec{mime: "audio/opus", fmtp_line: ""},
          %Livekit.Codec{mime: "video/H264", fmtp_line: "profile-level-id=42e01f"}
        ],
        metadata: "test metadata",
        num_participants: 2,
        num_publishers: 1,
        active_recording: false,
        version: %Livekit.TimedVersion{unix_micro: 1640995200000000, ticks: 1}
      }

      room = TwirpUtils.proto_to_room(proto_room)

      assert %Room{} = room
      assert room.name == "test-room"
      assert room.sid == "RM_123"
      assert room.empty_timeout == 300
      assert room.departure_timeout == 20
      assert room.max_participants == 10
      assert room.creation_time == 1640995200
      assert room.turn_password == "password123"
      assert room.metadata == "test metadata"
      assert room.num_participants == 2
      assert room.num_publishers == 1
      assert room.active_recording == false
      
      assert length(room.enabled_codecs) == 2
      assert %{mime: "audio/opus", fmtp_line: ""} in room.enabled_codecs
      assert %{mime: "video/H264", fmtp_line: "profile-level-id=42e01f"} in room.enabled_codecs
      
      assert room.version == %{unix_micro: 1640995200000000, ticks: 1}
    end

    test "handles room with nil enabled_codecs" do
      proto_room = %Livekit.Room{
        name: "test-room",
        sid: "RM_123",
        enabled_codecs: nil
      }

      room = TwirpUtils.proto_to_room(proto_room)
      assert room.enabled_codecs == []
    end

    test "handles room with nil version" do
      proto_room = %Livekit.Room{
        name: "test-room",
        sid: "RM_123",
        version: nil
      }

      room = TwirpUtils.proto_to_room(proto_room)
      assert room.version == nil
    end
  end

  describe "proto_to_participant/1" do
    test "converts protobuf participant to map" do
      proto_participant = %Livekit.ParticipantInfo{
        sid: "PA_123",
        identity: "user123",
        state: :ACTIVE,
        tracks: [
          %Livekit.TrackInfo{
            sid: "TR_123",
            type: :AUDIO,
            name: "microphone",
            muted: false
          }
        ],
        metadata: "user metadata",
        joined_at: 1640995200,
        name: "John Doe",
        version: 1,
        permission: %Livekit.ParticipantPermission{
          can_subscribe: true,
          can_publish: true,
          can_publish_data: true,
          hidden: false,
          recorder: false
        },
        region: "us-west-2",
        is_publisher: true,
        kind: :STANDARD,
        attributes: %{"role" => "host", "team" => "engineering"},
        disconnected_at: 0
      }

      participant = TwirpUtils.proto_to_participant(proto_participant)

      assert participant.sid == "PA_123"
      assert participant.identity == "user123"
      assert participant.state == :ACTIVE
      assert participant.metadata == "user metadata"
      assert participant.joined_at == 1640995200
      assert participant.name == "John Doe"
      assert participant.version == 1
      assert participant.region == "us-west-2"
      assert participant.is_publisher == true
      assert participant.kind == :STANDARD
      assert participant.attributes == %{"role" => "host", "team" => "engineering"}
      assert participant.disconnected_at == 0
      
      assert length(participant.tracks) == 1
      track = List.first(participant.tracks)
      assert track.sid == "TR_123"
      assert track.type == :AUDIO
      assert track.name == "microphone"
      assert track.muted == false
      
      assert participant.permission.can_subscribe == true
      assert participant.permission.can_publish == true
      assert participant.permission.can_publish_data == true
      assert participant.permission.hidden == false
      assert participant.permission.recorder == false
    end

    test "handles participant with nil tracks" do
      proto_participant = %Livekit.ParticipantInfo{
        sid: "PA_123",
        identity: "user123",
        tracks: nil
      }

      participant = TwirpUtils.proto_to_participant(proto_participant)
      assert participant.tracks == []
    end

    test "handles participant with nil permission" do
      proto_participant = %Livekit.ParticipantInfo{
        sid: "PA_123",
        identity: "user123",
        permission: nil
      }

      participant = TwirpUtils.proto_to_participant(proto_participant)
      assert participant.permission == %{}
    end

    test "handles participant with nil attributes" do
      proto_participant = %Livekit.ParticipantInfo{
        sid: "PA_123",  
        identity: "user123",
        attributes: nil
      }

      participant = TwirpUtils.proto_to_participant(proto_participant)
      assert participant.attributes == %{}
    end
  end

  describe "proto_to_track/1" do
    test "converts protobuf track to map" do
      proto_track = %Livekit.TrackInfo{
        sid: "TR_123",
        type: :VIDEO,
        name: "camera",
        muted: false,
        width: 1920,
        height: 1080,
        simulcast: true,
        disable_dtx: false,
        source: :CAMERA,
        layers: [
          %Livekit.VideoLayer{
            quality: :HIGH,
            width: 1920,
            height: 1080,
            bitrate: 2000000,
            ssrc: 123456
          }
        ],
        mime_type: "video/H264",
        mid: "0",
        codecs: [
          %Livekit.Codec{mime: "video/H264", fmtp_line: "profile-level-id=42e01f"}
        ],
        stereo: false,
        disable_red: false,
        encryption: :NONE,
        stream: "stream123"
      }

      track = TwirpUtils.proto_to_track(proto_track)

      assert track.sid == "TR_123"
      assert track.type == :VIDEO
      assert track.name == "camera"
      assert track.muted == false
      assert track.width == 1920
      assert track.height == 1080
      assert track.simulcast == true
      assert track.disable_dtx == false
      assert track.source == :CAMERA
      assert track.mime_type == "video/H264"
      assert track.mid == "0"
      assert track.stereo == false
      assert track.disable_red == false
      assert track.encryption == :NONE
      assert track.stream == "stream123"
      
      assert length(track.layers) == 1
      layer = List.first(track.layers)
      assert layer.quality == :HIGH
      assert layer.width == 1920
      assert layer.height == 1080
      assert layer.bitrate == 2000000
      assert layer.ssrc == 123456
      
      assert length(track.codecs) == 1
      codec = List.first(track.codecs)
      assert codec.mime == "video/H264"
      assert codec.fmtp_line == "profile-level-id=42e01f"
    end

    test "handles track with nil layers" do
      proto_track = %Livekit.TrackInfo{
        sid: "TR_123",
        type: :AUDIO,
        layers: nil
      }

      track = TwirpUtils.proto_to_track(proto_track)
      assert track.layers == []
    end

    test "handles track with nil codecs" do
      proto_track = %Livekit.TrackInfo{
        sid: "TR_123",
        type: :AUDIO,
        codecs: nil
      }

      track = TwirpUtils.proto_to_track(proto_track)
      assert track.codecs == []
    end
  end

  # Test private helper functions through public interface
  describe "codec conversion" do
    test "converts valid codec" do
      proto_room = %Livekit.Room{
        name: "test",
        sid: "RM_123",
        enabled_codecs: [%Livekit.Codec{mime: "audio/opus", fmtp_line: "test"}]
      }

      room = TwirpUtils.proto_to_room(proto_room)
      codec = List.first(room.enabled_codecs)
      assert codec.mime == "audio/opus"
      assert codec.fmtp_line == "test"
    end

    test "handles invalid codec" do
      proto_room = %Livekit.Room{
        name: "test",
        sid: "RM_123",
        enabled_codecs: [nil]
      }

      room = TwirpUtils.proto_to_room(proto_room)
      codec = List.first(room.enabled_codecs)
      assert codec == %{}
    end
  end

  describe "layer conversion" do
    test "converts valid layer" do
      proto_track = %Livekit.TrackInfo{
        sid: "TR_123",
        layers: [%Livekit.VideoLayer{quality: :HIGH, width: 1920, height: 1080}]
      }

      track = TwirpUtils.proto_to_track(proto_track)
      layer = List.first(track.layers)
      assert layer.quality == :HIGH
      assert layer.width == 1920
      assert layer.height == 1080
    end

    test "handles invalid layer" do
      proto_track = %Livekit.TrackInfo{
        sid: "TR_123",
        layers: [nil]
      }

      track = TwirpUtils.proto_to_track(proto_track)
      layer = List.first(track.layers)
      assert layer == %{}
    end
  end

  describe "permission conversion" do
    test "converts valid permission" do
      proto_participant = %Livekit.ParticipantInfo{
        sid: "PA_123",
        identity: "user123",
        permission: %Livekit.ParticipantPermission{
          can_subscribe: true,
          can_publish: false,
          can_publish_data: true,
          can_publish_sources: [:CAMERA, :MICROPHONE],
          hidden: false,
          recorder: true,
          can_update_metadata: false,
          agent: true
        }
      }

      participant = TwirpUtils.proto_to_participant(proto_participant)
      perm = participant.permission
      assert perm.can_subscribe == true
      assert perm.can_publish == false
      assert perm.can_publish_data == true
      assert perm.can_publish_sources == [:CAMERA, :MICROPHONE]
      assert perm.hidden == false
      assert perm.recorder == true
      assert perm.can_update_metadata == false
      assert perm.agent == true
    end

    test "handles permission with nil can_publish_sources" do
      proto_participant = %Livekit.ParticipantInfo{
        sid: "PA_123",
        identity: "user123",
        permission: %Livekit.ParticipantPermission{
          can_subscribe: true,
          can_publish_sources: nil
        }
      }

      participant = TwirpUtils.proto_to_participant(proto_participant)
      assert participant.permission.can_publish_sources == []
    end
  end

  describe "version conversion" do
    test "converts valid version" do
      proto_room = %Livekit.Room{
        name: "test",
        sid: "RM_123",
        version: %Livekit.TimedVersion{unix_micro: 1640995200000000, ticks: 42}
      }

      room = TwirpUtils.proto_to_room(proto_room)
      assert room.version.unix_micro == 1640995200000000
      assert room.version.ticks == 42
    end

    test "handles invalid version" do
      proto_room = %Livekit.Room{
        name: "test",
        sid: "RM_123",
        version: nil
      }

      room = TwirpUtils.proto_to_room(proto_room)
      assert room.version == nil
    end
  end
end
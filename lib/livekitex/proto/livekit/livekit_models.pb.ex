defmodule Livekitex.Proto.Livekit.AudioCodec do
  use Protobuf,
    enum: true,
    full_name: "livekit.AudioCodec",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :DEFAULT_AC, 0
  field :OPUS, 1
  field :AAC, 2
  field :AC_MP3, 3
end

defmodule Livekitex.Proto.Livekit.VideoCodec do
  use Protobuf,
    enum: true,
    full_name: "livekit.VideoCodec",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :DEFAULT_VC, 0
  field :H264_BASELINE, 1
  field :H264_MAIN, 2
  field :H264_HIGH, 3
  field :VP8, 4
end

defmodule Livekitex.Proto.Livekit.ImageCodec do
  use Protobuf,
    enum: true,
    full_name: "livekit.ImageCodec",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :IC_DEFAULT, 0
  field :IC_JPEG, 1
end

defmodule Livekitex.Proto.Livekit.BackupCodecPolicy do
  @moduledoc """
  Policy for publisher to handle subscribers that are unable to support the primary codec of a track
  """

  use Protobuf,
    enum: true,
    full_name: "livekit.BackupCodecPolicy",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :PREFER_REGRESSION, 0
  field :SIMULCAST, 1
  field :REGRESSION, 2
end

defmodule Livekitex.Proto.Livekit.TrackType do
  use Protobuf,
    enum: true,
    full_name: "livekit.TrackType",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :AUDIO, 0
  field :VIDEO, 1
  field :DATA, 2
end

defmodule Livekitex.Proto.Livekit.TrackSource do
  use Protobuf,
    enum: true,
    full_name: "livekit.TrackSource",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :UNKNOWN, 0
  field :CAMERA, 1
  field :MICROPHONE, 2
  field :SCREEN_SHARE, 3
  field :SCREEN_SHARE_AUDIO, 4
end

defmodule Livekitex.Proto.Livekit.DataTrackExtensionID do
  use Protobuf,
    enum: true,
    full_name: "livekit.DataTrackExtensionID",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :DTEI_INVALID, 0
  field :DTEI_E2EE, 1
  field :DTEI_USER_TIMESTAMP, 2
  field :DTEI_PARTICIPANT_SID, 255
end

defmodule Livekitex.Proto.Livekit.VideoQuality do
  use Protobuf,
    enum: true,
    full_name: "livekit.VideoQuality",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :LOW, 0
  field :MEDIUM, 1
  field :HIGH, 2
  field :OFF, 3
end

defmodule Livekitex.Proto.Livekit.ConnectionQuality do
  use Protobuf,
    enum: true,
    full_name: "livekit.ConnectionQuality",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :POOR, 0
  field :GOOD, 1
  field :EXCELLENT, 2
  field :LOST, 3
end

defmodule Livekitex.Proto.Livekit.ClientConfigSetting do
  use Protobuf,
    enum: true,
    full_name: "livekit.ClientConfigSetting",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :UNSET, 0
  field :DISABLED, 1
  field :ENABLED, 2
end

defmodule Livekitex.Proto.Livekit.DisconnectReason do
  use Protobuf,
    enum: true,
    full_name: "livekit.DisconnectReason",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :UNKNOWN_REASON, 0
  field :CLIENT_INITIATED, 1
  field :DUPLICATE_IDENTITY, 2
  field :SERVER_SHUTDOWN, 3
  field :PARTICIPANT_REMOVED, 4
  field :ROOM_DELETED, 5
  field :STATE_MISMATCH, 6
  field :JOIN_FAILURE, 7
  field :MIGRATION, 8
  field :SIGNAL_CLOSE, 9
  field :ROOM_CLOSED, 10
  field :USER_UNAVAILABLE, 11
  field :USER_REJECTED, 12
  field :SIP_TRUNK_FAILURE, 13
  field :CONNECTION_TIMEOUT, 14
  field :MEDIA_FAILURE, 15
  field :AGENT_ERROR, 16
end

defmodule Livekitex.Proto.Livekit.RoomEndReason do
  @moduledoc """
  why a room ended, reported on room-ended telemetry
  """

  use Protobuf,
    enum: true,
    full_name: "livekit.RoomEndReason",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :ROOM_END_UNKNOWN, 0
  field :ROOM_END_API_DELETE, 1
  field :ROOM_END_IDLE_TIMEOUT, 2
  field :ROOM_END_SERVER_SHUTDOWN, 3
  field :ROOM_END_SUPERSEDED, 4
  field :ROOM_END_OPEN_FAILED, 5
end

defmodule Livekitex.Proto.Livekit.ReconnectReason do
  use Protobuf,
    enum: true,
    full_name: "livekit.ReconnectReason",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :RR_UNKNOWN, 0
  field :RR_SIGNAL_DISCONNECTED, 1
  field :RR_PUBLISHER_FAILED, 2
  field :RR_SUBSCRIBER_FAILED, 3
  field :RR_SWITCH_CANDIDATE, 4
end

defmodule Livekitex.Proto.Livekit.SubscriptionError do
  use Protobuf,
    enum: true,
    full_name: "livekit.SubscriptionError",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :SE_UNKNOWN, 0
  field :SE_CODEC_UNSUPPORTED, 1
  field :SE_TRACK_NOTFOUND, 2
end

defmodule Livekitex.Proto.Livekit.AudioTrackFeature do
  use Protobuf,
    enum: true,
    full_name: "livekit.AudioTrackFeature",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :TF_STEREO, 0
  field :TF_NO_DTX, 1
  field :TF_AUTO_GAIN_CONTROL, 2
  field :TF_ECHO_CANCELLATION, 3
  field :TF_NOISE_SUPPRESSION, 4
  field :TF_ENHANCED_NOISE_CANCELLATION, 5
  field :TF_PRECONNECT_BUFFER, 6
end

defmodule Livekitex.Proto.Livekit.PacketTrailerFeature do
  use Protobuf,
    enum: true,
    full_name: "livekit.PacketTrailerFeature",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :PTF_USER_TIMESTAMP, 0
  field :PTF_FRAME_ID, 1
  field :PTF_USER_DATA, 2
end

defmodule Livekitex.Proto.Livekit.ParticipantInfo.State do
  use Protobuf,
    enum: true,
    full_name: "livekit.ParticipantInfo.State",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :JOINING, 0
  field :JOINED, 1
  field :ACTIVE, 2
  field :DISCONNECTED, 3
end

defmodule Livekitex.Proto.Livekit.ParticipantInfo.Kind do
  use Protobuf,
    enum: true,
    full_name: "livekit.ParticipantInfo.Kind",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :STANDARD, 0
  field :INGRESS, 1
  field :EGRESS, 2
  field :SIP, 3
  field :AGENT, 4
  field :CONNECTOR, 7
  field :BRIDGE, 8
end

defmodule Livekitex.Proto.Livekit.ParticipantInfo.KindDetail do
  use Protobuf,
    enum: true,
    full_name: "livekit.ParticipantInfo.KindDetail",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :CLOUD_AGENT, 0
  field :FORWARDED, 1
  field :CONNECTOR_WHATSAPP, 2
  field :CONNECTOR_TWILIO, 3
  field :BRIDGE_RTSP, 4
  field :SIMULATION, 5
end

defmodule Livekitex.Proto.Livekit.Encryption.Type do
  use Protobuf,
    enum: true,
    full_name: "livekit.Encryption.Type",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :NONE, 0
  field :GCM, 1
  field :CUSTOM, 2
end

defmodule Livekitex.Proto.Livekit.DataTrackFrameEncoding.WellKnownFrameEncoding do
  @moduledoc """
  Well-known encoding for frame payloads.

  Mirrors the well-known message encodings from the MCAP spec:
  https://mcap.dev/spec/registry#message-encodings
  """

  use Protobuf,
    enum: true,
    full_name: "livekit.DataTrackFrameEncoding.WellKnownFrameEncoding",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :WELL_KNOWN_FRAME_ENCODING_UNSPECIFIED, 0
  field :WELL_KNOWN_FRAME_ENCODING_ROS1, 1
  field :WELL_KNOWN_FRAME_ENCODING_CDR, 2
  field :WELL_KNOWN_FRAME_ENCODING_PROTOBUF, 3
  field :WELL_KNOWN_FRAME_ENCODING_FLATBUFFER, 4
  field :WELL_KNOWN_FRAME_ENCODING_CBOR, 5
  field :WELL_KNOWN_FRAME_ENCODING_MSGPACK, 6
  field :WELL_KNOWN_FRAME_ENCODING_JSON, 7
end

defmodule Livekitex.Proto.Livekit.DataTrackSchemaEncoding.WellKnownSchemaEncoding do
  @moduledoc """
  Well-known encoding for schema definition.

  Mirrors the well-known schema encodings from the MCAP spec:
  https://mcap.dev/spec/registry#schema-encodings
  """

  use Protobuf,
    enum: true,
    full_name: "livekit.DataTrackSchemaEncoding.WellKnownSchemaEncoding",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :WELL_KNOWN_SCHEMA_ENCODING_UNSPECIFIED, 0
  field :WELL_KNOWN_SCHEMA_ENCODING_PROTOBUF, 1
  field :WELL_KNOWN_SCHEMA_ENCODING_FLATBUFFER, 2
  field :WELL_KNOWN_SCHEMA_ENCODING_ROS1_MSG, 3
  field :WELL_KNOWN_SCHEMA_ENCODING_ROS2_MSG, 4
  field :WELL_KNOWN_SCHEMA_ENCODING_ROS2_IDL, 5
  field :WELL_KNOWN_SCHEMA_ENCODING_OMG_IDL, 6
  field :WELL_KNOWN_SCHEMA_ENCODING_JSON_SCHEMA, 7
end

defmodule Livekitex.Proto.Livekit.VideoLayer.Mode do
  use Protobuf,
    enum: true,
    full_name: "livekit.VideoLayer.Mode",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :MODE_UNUSED, 0
  field :ONE_SPATIAL_LAYER_PER_STREAM, 1
  field :MULTIPLE_SPATIAL_LAYERS_PER_STREAM, 2
  field :ONE_SPATIAL_LAYER_PER_STREAM_INCOMPLETE_RTCP_SR, 3
end

defmodule Livekitex.Proto.Livekit.DataPacket.Kind do
  use Protobuf,
    enum: true,
    full_name: "livekit.DataPacket.Kind",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :RELIABLE, 0
  field :LOSSY, 1
end

defmodule Livekitex.Proto.Livekit.ServerInfo.Edition do
  use Protobuf,
    enum: true,
    full_name: "livekit.ServerInfo.Edition",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :Standard, 0
  field :Cloud, 1
end

defmodule Livekitex.Proto.Livekit.ClientInfo.SDK do
  use Protobuf,
    enum: true,
    full_name: "livekit.ClientInfo.SDK",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :UNKNOWN, 0
  field :JS, 1
  field :SWIFT, 2
  field :ANDROID, 3
  field :FLUTTER, 4
  field :GO, 5
  field :UNITY, 6
  field :REACT_NATIVE, 7
  field :RUST, 8
  field :PYTHON, 9
  field :CPP, 10
  field :UNITY_WEB, 11
  field :NODE, 12
  field :UNREAL, 13
  field :ESP32, 14
  field :DOTNET, 15
end

defmodule Livekitex.Proto.Livekit.ClientInfo.Capability do
  @moduledoc """
  Optional capabilities advertised by the client at connect time. The SFU
  uses these flags to decide whether to enable features that require
  client-side support (e.g. passing RTP packet trailers through to the
  subscriber instead of stripping them).
  """

  use Protobuf,
    enum: true,
    full_name: "livekit.ClientInfo.Capability",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :CAP_UNUSED, 0
  field :CAP_PACKET_TRAILER, 1
  field :CAP_COMPRESSION_DEFLATE_RAW, 2
end

defmodule Livekitex.Proto.Livekit.DataStream.OperationType do
  @moduledoc """
  enum for operation types (specific to TextHeader)
  """

  use Protobuf,
    enum: true,
    full_name: "livekit.DataStream.OperationType",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :CREATE, 0
  field :UPDATE, 1
  field :DELETE, 2
  field :REACTION, 3
end

defmodule Livekitex.Proto.Livekit.DataStream.CompressionType do
  @moduledoc """
  The compression type of the whole data stream

  This will only get populated when send to participants with a
  client protocol >= 2 which advertise a client capability of CAP_COMPRESSION_DEFLATE_RAW
  """

  use Protobuf,
    enum: true,
    full_name: "livekit.DataStream.CompressionType",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :NONE, 0
  field :DEFLATE_RAW, 1
end

defmodule Livekitex.Proto.Livekit.Pagination do
  use Protobuf,
    full_name: "livekit.Pagination",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :after_id, 1, type: :string, json_name: "afterId", deprecated: false
  field :limit, 2, type: :int32
end

defmodule Livekitex.Proto.Livekit.TokenPagination do
  use Protobuf,
    full_name: "livekit.TokenPagination",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :token, 1, type: :string
end

defmodule Livekitex.Proto.Livekit.ListUpdate do
  @moduledoc """
  ListUpdate is used for updated APIs where 'repeated string' field is modified.
  """

  use Protobuf,
    full_name: "livekit.ListUpdate",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :set, 1, repeated: true, type: :string
  field :add, 2, repeated: true, type: :string
  field :remove, 3, repeated: true, type: :string
  field :clear, 4, type: :bool
end

defmodule Livekitex.Proto.Livekit.Room do
  use Protobuf, full_name: "livekit.Room", protoc_gen_elixir_version: "0.17.1", syntax: :proto3

  field :sid, 1, type: :string
  field :name, 2, type: :string
  field :empty_timeout, 3, type: :uint32, json_name: "emptyTimeout"
  field :departure_timeout, 14, type: :uint32, json_name: "departureTimeout"
  field :max_participants, 4, type: :uint32, json_name: "maxParticipants"
  field :creation_time, 5, type: :int64, json_name: "creationTime"
  field :creation_time_ms, 15, type: :int64, json_name: "creationTimeMs"
  field :turn_password, 6, type: :string, json_name: "turnPassword", deprecated: false

  field :enabled_codecs, 7,
    repeated: true,
    type: Livekitex.Proto.Livekit.Codec,
    json_name: "enabledCodecs"

  field :metadata, 8, type: :string, deprecated: false
  field :num_participants, 9, type: :uint32, json_name: "numParticipants"
  field :num_publishers, 11, type: :uint32, json_name: "numPublishers"
  field :active_recording, 10, type: :bool, json_name: "activeRecording"
  field :version, 13, type: Livekitex.Proto.Livekit.TimedVersion
end

defmodule Livekitex.Proto.Livekit.Codec do
  use Protobuf, full_name: "livekit.Codec", protoc_gen_elixir_version: "0.17.1", syntax: :proto3

  field :mime, 1, type: :string
  field :fmtp_line, 2, type: :string, json_name: "fmtpLine"
end

defmodule Livekitex.Proto.Livekit.PlayoutDelay do
  use Protobuf,
    full_name: "livekit.PlayoutDelay",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :enabled, 1, type: :bool
  field :min, 2, type: :uint32
  field :max, 3, type: :uint32
end

defmodule Livekitex.Proto.Livekit.ParticipantPermission do
  use Protobuf,
    full_name: "livekit.ParticipantPermission",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :can_subscribe, 1, type: :bool, json_name: "canSubscribe"
  field :can_publish, 2, type: :bool, json_name: "canPublish"
  field :can_publish_data, 3, type: :bool, json_name: "canPublishData"

  field :can_publish_sources, 9,
    repeated: true,
    type: Livekitex.Proto.Livekit.TrackSource,
    json_name: "canPublishSources",
    enum: true

  field :hidden, 7, type: :bool
  field :recorder, 8, type: :bool, deprecated: true
  field :can_update_metadata, 10, type: :bool, json_name: "canUpdateMetadata"
  field :agent, 11, type: :bool, deprecated: true
  field :can_subscribe_metrics, 12, type: :bool, json_name: "canSubscribeMetrics"
  field :can_manage_agent_session, 13, type: :bool, json_name: "canManageAgentSession"
end

defmodule Livekitex.Proto.Livekit.ParticipantInfo.AttributesEntry do
  use Protobuf,
    full_name: "livekit.ParticipantInfo.AttributesEntry",
    map: true,
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :key, 1, type: :string
  field :value, 2, type: :string
end

defmodule Livekitex.Proto.Livekit.ParticipantInfo do
  use Protobuf,
    full_name: "livekit.ParticipantInfo",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :sid, 1, type: :string
  field :identity, 2, type: :string
  field :state, 3, type: Livekitex.Proto.Livekit.ParticipantInfo.State, enum: true
  field :tracks, 4, repeated: true, type: Livekitex.Proto.Livekit.TrackInfo
  field :metadata, 5, type: :string, deprecated: false
  field :joined_at, 6, type: :int64, json_name: "joinedAt"
  field :joined_at_ms, 17, type: :int64, json_name: "joinedAtMs"
  field :name, 9, type: :string, deprecated: false
  field :version, 10, type: :uint32
  field :permission, 11, type: Livekitex.Proto.Livekit.ParticipantPermission
  field :region, 12, type: :string
  field :is_publisher, 13, type: :bool, json_name: "isPublisher"
  field :kind, 14, type: Livekitex.Proto.Livekit.ParticipantInfo.Kind, enum: true

  field :attributes, 15,
    repeated: true,
    type: Livekitex.Proto.Livekit.ParticipantInfo.AttributesEntry,
    map: true,
    deprecated: false

  field :disconnect_reason, 16,
    type: Livekitex.Proto.Livekit.DisconnectReason,
    json_name: "disconnectReason",
    enum: true

  field :kind_details, 18,
    repeated: true,
    type: Livekitex.Proto.Livekit.ParticipantInfo.KindDetail,
    json_name: "kindDetails",
    enum: true

  field :data_tracks, 19,
    repeated: true,
    type: Livekitex.Proto.Livekit.DataTrackInfo,
    json_name: "dataTracks"

  field :client_protocol, 20, type: :int32, json_name: "clientProtocol"

  field :capabilities, 21,
    repeated: true,
    type: Livekitex.Proto.Livekit.ClientInfo.Capability,
    enum: true
end

defmodule Livekitex.Proto.Livekit.Encryption do
  use Protobuf,
    full_name: "livekit.Encryption",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3
end

defmodule Livekitex.Proto.Livekit.SimulcastCodecInfo do
  use Protobuf,
    full_name: "livekit.SimulcastCodecInfo",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :mime_type, 1, type: :string, json_name: "mimeType"
  field :mid, 2, type: :string
  field :cid, 3, type: :string
  field :layers, 4, repeated: true, type: Livekitex.Proto.Livekit.VideoLayer

  field :video_layer_mode, 5,
    type: Livekitex.Proto.Livekit.VideoLayer.Mode,
    json_name: "videoLayerMode",
    enum: true

  field :sdp_cid, 6, type: :string, json_name: "sdpCid"
end

defmodule Livekitex.Proto.Livekit.TrackInfo do
  use Protobuf,
    full_name: "livekit.TrackInfo",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :sid, 1, type: :string
  field :type, 2, type: Livekitex.Proto.Livekit.TrackType, enum: true
  field :name, 3, type: :string, deprecated: false
  field :muted, 4, type: :bool
  field :width, 5, type: :uint32
  field :height, 6, type: :uint32
  field :simulcast, 7, type: :bool, deprecated: true
  field :disable_dtx, 8, type: :bool, json_name: "disableDtx", deprecated: true
  field :source, 9, type: Livekitex.Proto.Livekit.TrackSource, enum: true
  field :layers, 10, repeated: true, type: Livekitex.Proto.Livekit.VideoLayer, deprecated: true
  field :mime_type, 11, type: :string, json_name: "mimeType"
  field :mid, 12, type: :string
  field :codecs, 13, repeated: true, type: Livekitex.Proto.Livekit.SimulcastCodecInfo
  field :stereo, 14, type: :bool, deprecated: true
  field :disable_red, 15, type: :bool, json_name: "disableRed"
  field :encryption, 16, type: Livekitex.Proto.Livekit.Encryption.Type, enum: true
  field :stream, 17, type: :string
  field :version, 18, type: Livekitex.Proto.Livekit.TimedVersion

  field :audio_features, 19,
    repeated: true,
    type: Livekitex.Proto.Livekit.AudioTrackFeature,
    json_name: "audioFeatures",
    enum: true

  field :backup_codec_policy, 20,
    type: Livekitex.Proto.Livekit.BackupCodecPolicy,
    json_name: "backupCodecPolicy",
    enum: true

  field :packet_trailer_features, 21,
    repeated: true,
    type: Livekitex.Proto.Livekit.PacketTrailerFeature,
    json_name: "packetTrailerFeatures",
    enum: true
end

defmodule Livekitex.Proto.Livekit.DataTrackInfo do
  use Protobuf,
    full_name: "livekit.DataTrackInfo",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :pub_handle, 1, type: :uint32, json_name: "pubHandle"
  field :sid, 2, type: :string
  field :name, 3, type: :string
  field :encryption, 4, type: Livekitex.Proto.Livekit.Encryption.Type, enum: true

  field :frame_encoding, 5,
    proto3_optional: true,
    type: Livekitex.Proto.Livekit.DataTrackFrameEncoding,
    json_name: "frameEncoding"

  field :schema, 6, proto3_optional: true, type: Livekitex.Proto.Livekit.DataTrackSchemaId
end

defmodule Livekitex.Proto.Livekit.DataTrackFrameEncoding do
  @moduledoc """
  Encoding for frame payloads.
  """

  use Protobuf,
    full_name: "livekit.DataTrackFrameEncoding",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  oneof :value, 0

  field :well_known, 1,
    type: Livekitex.Proto.Livekit.DataTrackFrameEncoding.WellKnownFrameEncoding,
    json_name: "wellKnown",
    enum: true,
    oneof: 0

  field :custom, 2, type: :string, oneof: 0
end

defmodule Livekitex.Proto.Livekit.DataTrackSchemaEncoding do
  @moduledoc """
  Encoding for schema definition.
  """

  use Protobuf,
    full_name: "livekit.DataTrackSchemaEncoding",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  oneof :value, 0

  field :well_known, 1,
    type: Livekitex.Proto.Livekit.DataTrackSchemaEncoding.WellKnownSchemaEncoding,
    json_name: "wellKnown",
    enum: true,
    oneof: 0

  field :custom, 2, type: :string, oneof: 0
end

defmodule Livekitex.Proto.Livekit.DataTrackSchemaId do
  @moduledoc """
  Identifier for a data track schema.

  Schemas with the same name but different encodings are distinct.
  """

  use Protobuf,
    full_name: "livekit.DataTrackSchemaId",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :name, 1, type: :string
  field :encoding, 2, type: Livekitex.Proto.Livekit.DataTrackSchemaEncoding
end

defmodule Livekitex.Proto.Livekit.DataTrackExtensionParticipantSid do
  use Protobuf,
    full_name: "livekit.DataTrackExtensionParticipantSid",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :id, 1, type: Livekitex.Proto.Livekit.DataTrackExtensionID, enum: true
  field :participant_sid, 2, type: :string, json_name: "participantSid"
end

defmodule Livekitex.Proto.Livekit.DataTrackSubscriptionOptions do
  use Protobuf,
    full_name: "livekit.DataTrackSubscriptionOptions",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :target_fps, 1, proto3_optional: true, type: :uint32, json_name: "targetFps"
end

defmodule Livekitex.Proto.Livekit.DataBlobKey do
  @moduledoc """
  Key used to uniquely identify a data blob for storage and retrieval.
  """

  use Protobuf,
    full_name: "livekit.DataBlobKey",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  oneof :key, 0

  field :generic, 1, type: :string, oneof: 0

  field :schema_id, 2,
    type: Livekitex.Proto.Livekit.DataTrackSchemaId,
    json_name: "schemaId",
    oneof: 0,
    deprecated: false
end

defmodule Livekitex.Proto.Livekit.DataBlob do
  @moduledoc """
  A blob of data stored in a room identified by a unique key.
  """

  use Protobuf,
    full_name: "livekit.DataBlob",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :key, 1, type: Livekitex.Proto.Livekit.DataBlobKey
  field :contents, 2, type: :bytes, deprecated: false
end

defmodule Livekitex.Proto.Livekit.VideoLayer do
  @moduledoc """
  provide information about available spatial layers
  """

  use Protobuf,
    full_name: "livekit.VideoLayer",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :quality, 1, type: Livekitex.Proto.Livekit.VideoQuality, enum: true
  field :width, 2, type: :uint32
  field :height, 3, type: :uint32
  field :bitrate, 4, type: :uint32
  field :ssrc, 5, type: :uint32
  field :spatial_layer, 6, type: :int32, json_name: "spatialLayer"
  field :rid, 7, type: :string
  field :repair_ssrc, 8, type: :uint32, json_name: "repairSsrc"
end

defmodule Livekitex.Proto.Livekit.DataPacket do
  @moduledoc """
  new DataPacket API
  """

  use Protobuf,
    full_name: "livekit.DataPacket",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  oneof :value, 0

  field :kind, 1, type: Livekitex.Proto.Livekit.DataPacket.Kind, enum: true, deprecated: true
  field :participant_identity, 4, type: :string, json_name: "participantIdentity"

  field :destination_identities, 5,
    repeated: true,
    type: :string,
    json_name: "destinationIdentities"

  field :user, 2, type: Livekitex.Proto.Livekit.UserPacket, oneof: 0
  field :speaker, 3, type: Livekitex.Proto.Livekit.ActiveSpeakerUpdate, oneof: 0, deprecated: true
  field :sip_dtmf, 6, type: Livekitex.Proto.Livekit.SipDTMF, json_name: "sipDtmf", oneof: 0
  field :transcription, 7, type: Livekitex.Proto.Livekit.Transcription, oneof: 0
  field :metrics, 8, type: Livekitex.Proto.Livekit.MetricsBatch, oneof: 0

  field :chat_message, 9,
    type: Livekitex.Proto.Livekit.ChatMessage,
    json_name: "chatMessage",
    oneof: 0

  field :rpc_request, 10,
    type: Livekitex.Proto.Livekit.RpcRequest,
    json_name: "rpcRequest",
    oneof: 0

  field :rpc_ack, 11, type: Livekitex.Proto.Livekit.RpcAck, json_name: "rpcAck", oneof: 0

  field :rpc_response, 12,
    type: Livekitex.Proto.Livekit.RpcResponse,
    json_name: "rpcResponse",
    oneof: 0

  field :stream_header, 13,
    type: Livekitex.Proto.Livekit.DataStream.Header,
    json_name: "streamHeader",
    oneof: 0

  field :stream_chunk, 14,
    type: Livekitex.Proto.Livekit.DataStream.Chunk,
    json_name: "streamChunk",
    oneof: 0

  field :stream_trailer, 15,
    type: Livekitex.Proto.Livekit.DataStream.Trailer,
    json_name: "streamTrailer",
    oneof: 0

  field :encrypted_packet, 18,
    type: Livekitex.Proto.Livekit.EncryptedPacket,
    json_name: "encryptedPacket",
    oneof: 0

  field :sequence, 16, type: :uint32
  field :participant_sid, 17, type: :string, json_name: "participantSid"
end

defmodule Livekitex.Proto.Livekit.EncryptedPacket do
  use Protobuf,
    full_name: "livekit.EncryptedPacket",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :encryption_type, 1,
    type: Livekitex.Proto.Livekit.Encryption.Type,
    json_name: "encryptionType",
    enum: true

  field :iv, 2, type: :bytes
  field :key_index, 3, type: :uint32, json_name: "keyIndex"
  field :encrypted_value, 4, type: :bytes, json_name: "encryptedValue"
end

defmodule Livekitex.Proto.Livekit.EncryptedPacketPayload do
  use Protobuf,
    full_name: "livekit.EncryptedPacketPayload",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  oneof :value, 0

  field :user, 1, type: Livekitex.Proto.Livekit.UserPacket, oneof: 0

  field :chat_message, 3,
    type: Livekitex.Proto.Livekit.ChatMessage,
    json_name: "chatMessage",
    oneof: 0

  field :rpc_request, 4,
    type: Livekitex.Proto.Livekit.RpcRequest,
    json_name: "rpcRequest",
    oneof: 0

  field :rpc_ack, 5, type: Livekitex.Proto.Livekit.RpcAck, json_name: "rpcAck", oneof: 0

  field :rpc_response, 6,
    type: Livekitex.Proto.Livekit.RpcResponse,
    json_name: "rpcResponse",
    oneof: 0

  field :stream_header, 7,
    type: Livekitex.Proto.Livekit.DataStream.Header,
    json_name: "streamHeader",
    oneof: 0

  field :stream_chunk, 8,
    type: Livekitex.Proto.Livekit.DataStream.Chunk,
    json_name: "streamChunk",
    oneof: 0

  field :stream_trailer, 9,
    type: Livekitex.Proto.Livekit.DataStream.Trailer,
    json_name: "streamTrailer",
    oneof: 0
end

defmodule Livekitex.Proto.Livekit.ActiveSpeakerUpdate do
  use Protobuf,
    deprecated: true,
    full_name: "livekit.ActiveSpeakerUpdate",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :speakers, 1, repeated: true, type: Livekitex.Proto.Livekit.SpeakerInfo
end

defmodule Livekitex.Proto.Livekit.SpeakerInfo do
  use Protobuf,
    full_name: "livekit.SpeakerInfo",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :sid, 1, type: :string
  field :level, 2, type: :float
  field :active, 3, type: :bool
end

defmodule Livekitex.Proto.Livekit.UserPacket do
  use Protobuf,
    full_name: "livekit.UserPacket",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :participant_sid, 1, type: :string, json_name: "participantSid", deprecated: true

  field :participant_identity, 5,
    type: :string,
    json_name: "participantIdentity",
    deprecated: true

  field :payload, 2, type: :bytes

  field :destination_sids, 3,
    repeated: true,
    type: :string,
    json_name: "destinationSids",
    deprecated: true

  field :destination_identities, 6,
    repeated: true,
    type: :string,
    json_name: "destinationIdentities",
    deprecated: true

  field :topic, 4, proto3_optional: true, type: :string
  field :id, 8, proto3_optional: true, type: :string
  field :start_time, 9, proto3_optional: true, type: :uint64, json_name: "startTime"
  field :end_time, 10, proto3_optional: true, type: :uint64, json_name: "endTime"
  field :nonce, 11, type: :bytes
end

defmodule Livekitex.Proto.Livekit.SipDTMF do
  use Protobuf, full_name: "livekit.SipDTMF", protoc_gen_elixir_version: "0.17.1", syntax: :proto3

  field :code, 3, type: :uint32
  field :digit, 4, type: :string
end

defmodule Livekitex.Proto.Livekit.Transcription do
  use Protobuf,
    full_name: "livekit.Transcription",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :transcribed_participant_identity, 2,
    type: :string,
    json_name: "transcribedParticipantIdentity"

  field :track_id, 3, type: :string, json_name: "trackId", deprecated: false
  field :segments, 4, repeated: true, type: Livekitex.Proto.Livekit.TranscriptionSegment
end

defmodule Livekitex.Proto.Livekit.TranscriptionSegment do
  use Protobuf,
    full_name: "livekit.TranscriptionSegment",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :id, 1, type: :string
  field :text, 2, type: :string
  field :start_time, 3, type: :uint64, json_name: "startTime"
  field :end_time, 4, type: :uint64, json_name: "endTime"
  field :final, 5, type: :bool
  field :language, 6, type: :string
end

defmodule Livekitex.Proto.Livekit.ChatMessage do
  use Protobuf,
    full_name: "livekit.ChatMessage",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :id, 1, type: :string
  field :timestamp, 2, type: :int64
  field :edit_timestamp, 3, proto3_optional: true, type: :int64, json_name: "editTimestamp"
  field :message, 4, type: :string
  field :deleted, 5, type: :bool
  field :generated, 6, type: :bool
end

defmodule Livekitex.Proto.Livekit.RpcRequest do
  use Protobuf,
    full_name: "livekit.RpcRequest",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :id, 1, type: :string
  field :method, 2, type: :string
  field :payload, 3, type: :string
  field :response_timeout_ms, 4, type: :uint32, json_name: "responseTimeoutMs"
  field :version, 5, type: :uint32
  field :compressed_payload, 6, type: :bytes, json_name: "compressedPayload"
end

defmodule Livekitex.Proto.Livekit.RpcAck do
  use Protobuf, full_name: "livekit.RpcAck", protoc_gen_elixir_version: "0.17.1", syntax: :proto3

  field :request_id, 1, type: :string, json_name: "requestId", deprecated: false
end

defmodule Livekitex.Proto.Livekit.RpcResponse do
  use Protobuf,
    full_name: "livekit.RpcResponse",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  oneof :value, 0

  field :request_id, 1, type: :string, json_name: "requestId", deprecated: false
  field :payload, 2, type: :string, oneof: 0
  field :error, 3, type: Livekitex.Proto.Livekit.RpcError, oneof: 0
  field :compressed_payload, 4, type: :bytes, json_name: "compressedPayload", oneof: 0
end

defmodule Livekitex.Proto.Livekit.RpcError do
  use Protobuf,
    full_name: "livekit.RpcError",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :code, 1, type: :uint32
  field :message, 2, type: :string
  field :data, 3, type: :string
end

defmodule Livekitex.Proto.Livekit.ParticipantTracks do
  use Protobuf,
    full_name: "livekit.ParticipantTracks",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :participant_sid, 1, type: :string, json_name: "participantSid"
  field :track_sids, 2, repeated: true, type: :string, json_name: "trackSids"
end

defmodule Livekitex.Proto.Livekit.ServerInfo do
  @moduledoc """
  details about the server
  """

  use Protobuf,
    full_name: "livekit.ServerInfo",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :edition, 1, type: Livekitex.Proto.Livekit.ServerInfo.Edition, enum: true
  field :version, 2, type: :string
  field :protocol, 3, type: :int32
  field :region, 4, type: :string
  field :node_id, 5, type: :string, json_name: "nodeId", deprecated: false
  field :debug_info, 6, type: :string, json_name: "debugInfo"
  field :agent_protocol, 7, type: :int32, json_name: "agentProtocol"
end

defmodule Livekitex.Proto.Livekit.ClientInfo do
  @moduledoc """
  details about the client
  """

  use Protobuf,
    full_name: "livekit.ClientInfo",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :sdk, 1, type: Livekitex.Proto.Livekit.ClientInfo.SDK, enum: true
  field :version, 2, type: :string
  field :protocol, 3, type: :int32
  field :os, 4, type: :string
  field :os_version, 5, type: :string, json_name: "osVersion"
  field :device_model, 6, type: :string, json_name: "deviceModel"
  field :browser, 7, type: :string
  field :browser_version, 8, type: :string, json_name: "browserVersion"
  field :address, 9, type: :string
  field :network, 10, type: :string
  field :other_sdks, 11, type: :string, json_name: "otherSdks"
  field :client_protocol, 12, type: :int32, json_name: "clientProtocol"

  field :capabilities, 13,
    repeated: true,
    type: Livekitex.Proto.Livekit.ClientInfo.Capability,
    enum: true
end

defmodule Livekitex.Proto.Livekit.ClientConfiguration do
  @moduledoc """
  server provided client configuration
  """

  use Protobuf,
    full_name: "livekit.ClientConfiguration",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :video, 1, type: Livekitex.Proto.Livekit.VideoConfiguration
  field :screen, 2, type: Livekitex.Proto.Livekit.VideoConfiguration

  field :resume_connection, 3,
    type: Livekitex.Proto.Livekit.ClientConfigSetting,
    json_name: "resumeConnection",
    enum: true

  field :disabled_codecs, 4,
    type: Livekitex.Proto.Livekit.DisabledCodecs,
    json_name: "disabledCodecs"

  field :force_relay, 5,
    type: Livekitex.Proto.Livekit.ClientConfigSetting,
    json_name: "forceRelay",
    enum: true
end

defmodule Livekitex.Proto.Livekit.VideoConfiguration do
  use Protobuf,
    full_name: "livekit.VideoConfiguration",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :hardware_encoder, 1,
    type: Livekitex.Proto.Livekit.ClientConfigSetting,
    json_name: "hardwareEncoder",
    enum: true
end

defmodule Livekitex.Proto.Livekit.DisabledCodecs do
  use Protobuf,
    full_name: "livekit.DisabledCodecs",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :codecs, 1, repeated: true, type: Livekitex.Proto.Livekit.Codec
  field :publish, 2, repeated: true, type: Livekitex.Proto.Livekit.Codec
end

defmodule Livekitex.Proto.Livekit.RTPDrift do
  use Protobuf,
    full_name: "livekit.RTPDrift",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :start_time, 1, type: Google.Protobuf.Timestamp, json_name: "startTime"
  field :end_time, 2, type: Google.Protobuf.Timestamp, json_name: "endTime"
  field :duration, 3, type: :double
  field :start_timestamp, 4, type: :uint64, json_name: "startTimestamp"
  field :end_timestamp, 5, type: :uint64, json_name: "endTimestamp"
  field :rtp_clock_ticks, 6, type: :uint64, json_name: "rtpClockTicks"
  field :drift_samples, 7, type: :int64, json_name: "driftSamples"
  field :drift_ms, 8, type: :double, json_name: "driftMs"
  field :clock_rate, 9, type: :double, json_name: "clockRate"
end

defmodule Livekitex.Proto.Livekit.RTPStats.GapHistogramEntry do
  use Protobuf,
    full_name: "livekit.RTPStats.GapHistogramEntry",
    map: true,
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :key, 1, type: :int32
  field :value, 2, type: :uint32
end

defmodule Livekitex.Proto.Livekit.RTPStats do
  use Protobuf,
    full_name: "livekit.RTPStats",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :start_time, 1, type: Google.Protobuf.Timestamp, json_name: "startTime"
  field :end_time, 2, type: Google.Protobuf.Timestamp, json_name: "endTime"
  field :duration, 3, type: :double
  field :packets, 4, type: :uint32
  field :packet_rate, 5, type: :double, json_name: "packetRate"
  field :bytes, 6, type: :uint64
  field :header_bytes, 39, type: :uint64, json_name: "headerBytes"
  field :bitrate, 7, type: :double
  field :packets_lost, 8, type: :uint32, json_name: "packetsLost"
  field :packet_loss_rate, 9, type: :double, json_name: "packetLossRate"
  field :packet_loss_percentage, 10, type: :float, json_name: "packetLossPercentage"
  field :packets_duplicate, 11, type: :uint32, json_name: "packetsDuplicate"
  field :packet_duplicate_rate, 12, type: :double, json_name: "packetDuplicateRate"
  field :bytes_duplicate, 13, type: :uint64, json_name: "bytesDuplicate"
  field :header_bytes_duplicate, 40, type: :uint64, json_name: "headerBytesDuplicate"
  field :bitrate_duplicate, 14, type: :double, json_name: "bitrateDuplicate"
  field :packets_padding, 15, type: :uint32, json_name: "packetsPadding"
  field :packet_padding_rate, 16, type: :double, json_name: "packetPaddingRate"
  field :bytes_padding, 17, type: :uint64, json_name: "bytesPadding"
  field :header_bytes_padding, 41, type: :uint64, json_name: "headerBytesPadding"
  field :bitrate_padding, 18, type: :double, json_name: "bitratePadding"
  field :packets_out_of_order, 19, type: :uint32, json_name: "packetsOutOfOrder"
  field :frames, 20, type: :uint32
  field :frame_rate, 21, type: :double, json_name: "frameRate"
  field :jitter_current, 22, type: :double, json_name: "jitterCurrent"
  field :jitter_max, 23, type: :double, json_name: "jitterMax"

  field :gap_histogram, 24,
    repeated: true,
    type: Livekitex.Proto.Livekit.RTPStats.GapHistogramEntry,
    json_name: "gapHistogram",
    map: true

  field :nacks, 25, type: :uint32
  field :nack_acks, 37, type: :uint32, json_name: "nackAcks"
  field :nack_misses, 26, type: :uint32, json_name: "nackMisses"
  field :nack_repeated, 38, type: :uint32, json_name: "nackRepeated"
  field :plis, 27, type: :uint32
  field :last_pli, 28, type: Google.Protobuf.Timestamp, json_name: "lastPli"
  field :firs, 29, type: :uint32
  field :last_fir, 30, type: Google.Protobuf.Timestamp, json_name: "lastFir"
  field :rtt_current, 31, type: :uint32, json_name: "rttCurrent"
  field :rtt_max, 32, type: :uint32, json_name: "rttMax"
  field :key_frames, 33, type: :uint32, json_name: "keyFrames"
  field :last_key_frame, 34, type: Google.Protobuf.Timestamp, json_name: "lastKeyFrame"
  field :layer_lock_plis, 35, type: :uint32, json_name: "layerLockPlis"
  field :last_layer_lock_pli, 36, type: Google.Protobuf.Timestamp, json_name: "lastLayerLockPli"
  field :packet_drift, 44, type: Livekitex.Proto.Livekit.RTPDrift, json_name: "packetDrift"
  field :ntp_report_drift, 45, type: Livekitex.Proto.Livekit.RTPDrift, json_name: "ntpReportDrift"

  field :rebased_report_drift, 46,
    type: Livekitex.Proto.Livekit.RTPDrift,
    json_name: "rebasedReportDrift"

  field :received_report_drift, 47,
    type: Livekitex.Proto.Livekit.RTPDrift,
    json_name: "receivedReportDrift"

  field :fec_packets, 48, type: :uint32, json_name: "fecPackets"
  field :fec_bytes, 49, type: :uint64, json_name: "fecBytes"
  field :fec_packets_discarded, 50, type: :uint32, json_name: "fecPacketsDiscarded"
  field :fec_packets_recovered, 51, type: :uint32, json_name: "fecPacketsRecovered"
end

defmodule Livekitex.Proto.Livekit.RTCPSenderReportState do
  use Protobuf,
    full_name: "livekit.RTCPSenderReportState",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :rtp_timestamp, 1, type: :uint32, json_name: "rtpTimestamp"
  field :rtp_timestamp_ext, 2, type: :uint64, json_name: "rtpTimestampExt"
  field :ntp_timestamp, 3, type: :uint64, json_name: "ntpTimestamp"
  field :at, 4, type: :int64
  field :at_adjusted, 5, type: :int64, json_name: "atAdjusted"
  field :packets, 6, type: :uint32
  field :octets, 7, type: :uint64
end

defmodule Livekitex.Proto.Livekit.RTPForwarderState do
  use Protobuf,
    full_name: "livekit.RTPForwarderState",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  oneof :codec_munger, 0

  field :started, 1, type: :bool
  field :reference_layer_spatial, 2, type: :int32, json_name: "referenceLayerSpatial"
  field :pre_start_time, 3, type: :int64, json_name: "preStartTime"
  field :ext_first_timestamp, 4, type: :uint64, json_name: "extFirstTimestamp"
  field :dummy_start_timestamp_offset, 5, type: :uint64, json_name: "dummyStartTimestampOffset"
  field :rtp_munger, 6, type: Livekitex.Proto.Livekit.RTPMungerState, json_name: "rtpMunger"

  field :vp8_munger, 7,
    type: Livekitex.Proto.Livekit.VP8MungerState,
    json_name: "vp8Munger",
    oneof: 0

  field :sender_report_state, 8,
    repeated: true,
    type: Livekitex.Proto.Livekit.RTCPSenderReportState,
    json_name: "senderReportState"

  field :dependency_descriptor_forwarder, 9,
    type: Livekitex.Proto.Livekit.DependencyDescriptorForwarderState,
    json_name: "dependencyDescriptorForwarder"
end

defmodule Livekitex.Proto.Livekit.DependencyDescriptorForwarderState do
  @moduledoc """
  State of a forwarder that writes the dependency descriptor for the subscriber, so
  its frame numbers continue on a migrated subscriber.
  """

  use Protobuf,
    full_name: "livekit.DependencyDescriptorForwarderState",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :ext_last_frame_number, 1, type: :uint64, json_name: "extLastFrameNumber"
end

defmodule Livekitex.Proto.Livekit.RTPMungerState do
  use Protobuf,
    full_name: "livekit.RTPMungerState",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :ext_last_sequence_number, 1, type: :uint64, json_name: "extLastSequenceNumber"

  field :ext_second_last_sequence_number, 2,
    type: :uint64,
    json_name: "extSecondLastSequenceNumber"

  field :ext_last_timestamp, 3, type: :uint64, json_name: "extLastTimestamp"
  field :ext_second_last_timestamp, 4, type: :uint64, json_name: "extSecondLastTimestamp"
  field :last_marker, 5, type: :bool, json_name: "lastMarker"
  field :second_last_marker, 6, type: :bool, json_name: "secondLastMarker"
end

defmodule Livekitex.Proto.Livekit.VP8MungerState do
  use Protobuf,
    full_name: "livekit.VP8MungerState",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :ext_last_picture_id, 1, type: :int32, json_name: "extLastPictureId", deprecated: false
  field :picture_id_used, 2, type: :bool, json_name: "pictureIdUsed"
  field :last_tl0_pic_idx, 3, type: :uint32, json_name: "lastTl0PicIdx"
  field :tl0_pic_idx_used, 4, type: :bool, json_name: "tl0PicIdxUsed"
  field :tid_used, 5, type: :bool, json_name: "tidUsed"
  field :last_key_idx, 6, type: :uint32, json_name: "lastKeyIdx"
  field :key_idx_used, 7, type: :bool, json_name: "keyIdxUsed"
end

defmodule Livekitex.Proto.Livekit.TimedVersion do
  use Protobuf,
    full_name: "livekit.TimedVersion",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :unix_micro, 1, type: :int64, json_name: "unixMicro"
  field :ticks, 2, type: :int32
end

defmodule Livekitex.Proto.Livekit.DataStream.TextHeader do
  @moduledoc """
  header properties specific to text streams
  """

  use Protobuf,
    full_name: "livekit.DataStream.TextHeader",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :operation_type, 1,
    type: Livekitex.Proto.Livekit.DataStream.OperationType,
    json_name: "operationType",
    enum: true

  field :version, 2, type: :int32
  field :reply_to_stream_id, 3, type: :string, json_name: "replyToStreamId", deprecated: false
  field :attached_stream_ids, 4, repeated: true, type: :string, json_name: "attachedStreamIds"
  field :generated, 5, type: :bool
end

defmodule Livekitex.Proto.Livekit.DataStream.ByteHeader do
  @moduledoc """
  header properties specific to byte or file streams
  """

  use Protobuf,
    full_name: "livekit.DataStream.ByteHeader",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :name, 1, type: :string
end

defmodule Livekitex.Proto.Livekit.DataStream.Header.AttributesEntry do
  use Protobuf,
    full_name: "livekit.DataStream.Header.AttributesEntry",
    map: true,
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :key, 1, type: :string
  field :value, 2, type: :string
end

defmodule Livekitex.Proto.Livekit.DataStream.Header do
  @moduledoc """
  main DataStream.Header that contains a oneof for specific headers
  """

  use Protobuf,
    full_name: "livekit.DataStream.Header",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  oneof :content_header, 0

  field :stream_id, 1, type: :string, json_name: "streamId", deprecated: false
  field :timestamp, 2, type: :int64
  field :topic, 3, type: :string
  field :mime_type, 4, type: :string, json_name: "mimeType"
  field :total_length, 5, proto3_optional: true, type: :uint64, json_name: "totalLength"

  field :encryption_type, 7,
    type: Livekitex.Proto.Livekit.Encryption.Type,
    json_name: "encryptionType",
    enum: true,
    deprecated: true

  field :attributes, 8,
    repeated: true,
    type: Livekitex.Proto.Livekit.DataStream.Header.AttributesEntry,
    map: true

  field :text_header, 9,
    type: Livekitex.Proto.Livekit.DataStream.TextHeader,
    json_name: "textHeader",
    oneof: 0

  field :byte_header, 10,
    type: Livekitex.Proto.Livekit.DataStream.ByteHeader,
    json_name: "byteHeader",
    oneof: 0

  field :inline_content, 11, proto3_optional: true, type: :bytes, json_name: "inlineContent"
  field :compression, 12, type: Livekitex.Proto.Livekit.DataStream.CompressionType, enum: true
end

defmodule Livekitex.Proto.Livekit.DataStream.Chunk do
  use Protobuf,
    full_name: "livekit.DataStream.Chunk",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :stream_id, 1, type: :string, json_name: "streamId", deprecated: false
  field :chunk_index, 2, type: :uint64, json_name: "chunkIndex"
  field :content, 3, type: :bytes
  field :version, 4, type: :int32
  field :iv, 5, proto3_optional: true, type: :bytes, deprecated: true
end

defmodule Livekitex.Proto.Livekit.DataStream.Trailer.AttributesEntry do
  use Protobuf,
    full_name: "livekit.DataStream.Trailer.AttributesEntry",
    map: true,
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :key, 1, type: :string
  field :value, 2, type: :string
end

defmodule Livekitex.Proto.Livekit.DataStream.Trailer do
  use Protobuf,
    full_name: "livekit.DataStream.Trailer",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :stream_id, 1, type: :string, json_name: "streamId", deprecated: false
  field :reason, 2, type: :string

  field :attributes, 3,
    repeated: true,
    type: Livekitex.Proto.Livekit.DataStream.Trailer.AttributesEntry,
    map: true
end

defmodule Livekitex.Proto.Livekit.DataStream do
  use Protobuf,
    full_name: "livekit.DataStream",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3
end

defmodule Livekitex.Proto.Livekit.FilterParams do
  use Protobuf,
    full_name: "livekit.FilterParams",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :include_events, 1, repeated: true, type: :string, json_name: "includeEvents"
  field :exclude_events, 2, repeated: true, type: :string, json_name: "excludeEvents"
end

defmodule Livekitex.Proto.Livekit.WebhookConfig do
  use Protobuf,
    full_name: "livekit.WebhookConfig",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :url, 1, type: :string
  field :signing_key, 2, type: :string, json_name: "signingKey"
  field :filter_params, 3, type: Livekitex.Proto.Livekit.FilterParams, json_name: "filterParams"
end

defmodule Livekitex.Proto.Livekit.SubscribedAudioCodec do
  use Protobuf,
    full_name: "livekit.SubscribedAudioCodec",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :codec, 1, type: :string
  field :enabled, 2, type: :bool
end

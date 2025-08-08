defmodule Livekit.TrackType do
  @moduledoc false

  use Protobuf, enum: true, protoc_gen_elixir_version: "0.14.0", syntax: :proto3

  field(:AUDIO, 0)
  field(:VIDEO, 1)
  field(:DATA, 2)
end

defmodule Livekit.TrackSource do
  @moduledoc false

  use Protobuf, enum: true, protoc_gen_elixir_version: "0.14.0", syntax: :proto3

  field(:UNKNOWN, 0)
  field(:CAMERA, 1)
  field(:MICROPHONE, 2)
  field(:SCREEN_SHARE, 3)
  field(:SCREEN_SHARE_AUDIO, 4)
end

defmodule Livekit.VideoQuality do
  @moduledoc false

  use Protobuf, enum: true, protoc_gen_elixir_version: "0.14.0", syntax: :proto3

  field(:LOW, 0)
  field(:MEDIUM, 1)
  field(:HIGH, 2)
  field(:OFF, 3)
end

defmodule Livekit.ParticipantInfo.State do
  @moduledoc false

  use Protobuf, enum: true, protoc_gen_elixir_version: "0.14.0", syntax: :proto3

  field(:JOINING, 0)
  field(:JOINED, 1)
  field(:ACTIVE, 2)
  field(:DISCONNECTED, 3)
end

defmodule Livekit.ParticipantInfo.Kind do
  @moduledoc false

  use Protobuf, enum: true, protoc_gen_elixir_version: "0.14.0", syntax: :proto3

  field(:STANDARD, 0)
  field(:INGRESS, 1)
  field(:EGRESS, 2)
  field(:SIP, 3)
  field(:AGENT, 4)
end

defmodule Livekit.DataPacket.Kind do
  @moduledoc false

  use Protobuf, enum: true, protoc_gen_elixir_version: "0.14.0", syntax: :proto3

  field(:RELIABLE, 0)
  field(:LOSSY, 1)
end

defmodule Livekit.Encryption.Type do
  @moduledoc false

  use Protobuf, enum: true, protoc_gen_elixir_version: "0.14.0", syntax: :proto3

  field(:NONE, 0)
  field(:GCM, 1)
  field(:CUSTOM, 2)
end

defmodule Livekit.Room do
  @moduledoc false

  use Protobuf, protoc_gen_elixir_version: "0.14.0", syntax: :proto3

  field(:sid, 1, type: :string)
  field(:name, 2, type: :string)
  field(:empty_timeout, 3, type: :uint32, json_name: "emptyTimeout")
  field(:departure_timeout, 14, type: :uint32, json_name: "departureTimeout")
  field(:max_participants, 4, type: :uint32, json_name: "maxParticipants")
  field(:creation_time, 5, type: :int64, json_name: "creationTime")
  field(:turn_password, 6, type: :string, json_name: "turnPassword")
  field(:enabled_codecs, 7, repeated: true, type: Livekit.Codec, json_name: "enabledCodecs")
  field(:metadata, 8, type: :string)
  field(:num_participants, 9, type: :uint32, json_name: "numParticipants")
  field(:num_publishers, 11, type: :uint32, json_name: "numPublishers")
  field(:active_recording, 10, type: :bool, json_name: "activeRecording")
  field(:version, 13, type: Livekit.TimedVersion)
end

defmodule Livekit.Codec do
  @moduledoc false

  use Protobuf, protoc_gen_elixir_version: "0.14.0", syntax: :proto3

  field(:mime, 1, type: :string)
  field(:fmtp_line, 2, type: :string, json_name: "fmtpLine")
end

defmodule Livekit.ParticipantPermission do
  @moduledoc false

  use Protobuf, protoc_gen_elixir_version: "0.14.0", syntax: :proto3

  field(:can_subscribe, 1, type: :bool, json_name: "canSubscribe")
  field(:can_publish, 2, type: :bool, json_name: "canPublish")
  field(:can_publish_data, 3, type: :bool, json_name: "canPublishData")

  field(:can_publish_sources, 9,
    repeated: true,
    type: Livekit.TrackSource,
    json_name: "canPublishSources",
    enum: true
  )

  field(:hidden, 7, type: :bool)
  field(:recorder, 8, type: :bool)
  field(:can_update_metadata, 10, type: :bool, json_name: "canUpdateMetadata")
  field(:agent, 11, type: :bool)
end

defmodule Livekit.ParticipantInfo.AttributesEntry do
  @moduledoc false

  use Protobuf, map: true, protoc_gen_elixir_version: "0.14.0", syntax: :proto3

  field(:key, 1, type: :string)
  field(:value, 2, type: :string)
end

defmodule Livekit.ParticipantInfo do
  @moduledoc false

  use Protobuf, protoc_gen_elixir_version: "0.14.0", syntax: :proto3

  field(:sid, 1, type: :string)
  field(:identity, 2, type: :string)
  field(:state, 3, type: Livekit.ParticipantInfo.State, enum: true)
  field(:tracks, 4, repeated: true, type: Livekit.TrackInfo)
  field(:metadata, 5, type: :string)
  field(:joined_at, 6, type: :int64, json_name: "joinedAt")
  field(:name, 9, type: :string)
  field(:version, 10, type: :uint32)
  field(:permission, 11, type: Livekit.ParticipantPermission)
  field(:region, 12, type: :string)
  field(:is_publisher, 13, type: :bool, json_name: "isPublisher")
  field(:kind, 14, type: Livekit.ParticipantInfo.Kind, enum: true)
  field(:attributes, 15, repeated: true, type: Livekit.ParticipantInfo.AttributesEntry, map: true)
  field(:disconnected_at, 16, type: :int64, json_name: "disconnectedAt")
end

defmodule Livekit.TrackInfo do
  @moduledoc false

  use Protobuf, protoc_gen_elixir_version: "0.14.0", syntax: :proto3

  field(:sid, 1, type: :string)
  field(:type, 2, type: Livekit.TrackType, enum: true)
  field(:name, 3, type: :string)
  field(:muted, 4, type: :bool)
  field(:width, 5, type: :uint32)
  field(:height, 6, type: :uint32)
  field(:simulcast, 7, type: :bool)
  field(:disable_dtx, 8, type: :bool, json_name: "disableDtx")
  field(:source, 9, type: Livekit.TrackSource, enum: true)
  field(:layers, 10, repeated: true, type: Livekit.VideoLayer)
  field(:mime_type, 11, type: :string, json_name: "mimeType")
  field(:mid, 12, type: :string)
  field(:codecs, 13, repeated: true, type: Livekit.Codec)
  field(:stereo, 14, type: :bool)
  field(:disable_red, 15, type: :bool, json_name: "disableRed")
  field(:encryption, 16, type: Livekit.Encryption.Type, enum: true)
  field(:stream, 17, type: :string)
  field(:version, 18, type: Livekit.TimedVersion)
  field(:audio_features, 19, type: Livekit.AudioTrackFeature, json_name: "audioFeatures")
end

defmodule Livekit.VideoLayer do
  @moduledoc false

  use Protobuf, protoc_gen_elixir_version: "0.14.0", syntax: :proto3

  field(:quality, 1, type: Livekit.VideoQuality, enum: true)
  field(:width, 2, type: :uint32)
  field(:height, 3, type: :uint32)
  field(:bitrate, 4, type: :uint32)
  field(:ssrc, 5, type: :uint32)
end

defmodule Livekit.DataPacket do
  @moduledoc false

  use Protobuf, protoc_gen_elixir_version: "0.14.0", syntax: :proto3

  oneof(:value, 0)

  field(:kind, 1, type: Livekit.DataPacket.Kind, enum: true)
  field(:user, 2, type: Livekit.UserPacket, oneof: 0)
  field(:speaker, 3, type: Livekit.ActiveSpeakerUpdate, oneof: 0)
  field(:sip_dtmf, 5, type: Livekit.SipDTMF, json_name: "sipDtmf", oneof: 0)
  field(:transcription, 6, type: Livekit.Transcription, oneof: 0)
end

defmodule Livekit.ActiveSpeakerUpdate do
  @moduledoc false

  use Protobuf, protoc_gen_elixir_version: "0.14.0", syntax: :proto3

  field(:speakers, 1, repeated: true, type: Livekit.SpeakerInfo)
end

defmodule Livekit.SpeakerInfo do
  @moduledoc false

  use Protobuf, protoc_gen_elixir_version: "0.14.0", syntax: :proto3

  field(:sid, 1, type: :string)
  field(:level, 2, type: :float)
  field(:active, 3, type: :bool)
end

defmodule Livekit.UserPacket do
  @moduledoc false

  use Protobuf, protoc_gen_elixir_version: "0.14.0", syntax: :proto3

  field(:participant_sid, 1, type: :string, json_name: "participantSid")
  field(:participant_identity, 5, type: :string, json_name: "participantIdentity")
  field(:payload, 2, type: :bytes)
  field(:destination_sids, 3, repeated: true, type: :string, json_name: "destinationSids")

  field(:destination_identities, 6,
    repeated: true,
    type: :string,
    json_name: "destinationIdentities"
  )

  field(:topic, 4, proto3_optional: true, type: :string)
  field(:id, 7, type: :uint64)
  field(:start_time, 8, type: :uint64, json_name: "startTime")
  field(:end_time, 9, type: :uint64, json_name: "endTime")
end

defmodule Livekit.ParticipantTracks do
  @moduledoc false

  use Protobuf, protoc_gen_elixir_version: "0.14.0", syntax: :proto3

  field(:participant_sid, 1, type: :string, json_name: "participantSid")
  field(:track_sids, 2, repeated: true, type: :string, json_name: "trackSids")
end

defmodule Livekit.Transcription do
  @moduledoc false

  use Protobuf, protoc_gen_elixir_version: "0.14.0", syntax: :proto3

  field(:transcribed_participant_identity, 1,
    type: :string,
    json_name: "transcribedParticipantIdentity"
  )

  field(:track_sid, 2, type: :string, json_name: "trackSid")
  field(:segments, 3, repeated: true, type: Livekit.TranscriptionSegment)
end

defmodule Livekit.TranscriptionSegment do
  @moduledoc false

  use Protobuf, protoc_gen_elixir_version: "0.14.0", syntax: :proto3

  field(:id, 1, type: :string)
  field(:text, 2, type: :string)
  field(:start_time, 3, type: :uint64, json_name: "startTime")
  field(:end_time, 4, type: :uint64, json_name: "endTime")
  field(:final, 5, type: :bool)
  field(:language, 6, type: :string)
end

defmodule Livekit.SipDTMF do
  @moduledoc false

  use Protobuf, protoc_gen_elixir_version: "0.14.0", syntax: :proto3

  field(:code, 3, type: :uint32)
  field(:digit, 4, type: :string)
end

defmodule Livekit.TimedVersion do
  @moduledoc false

  use Protobuf, protoc_gen_elixir_version: "0.14.0", syntax: :proto3

  field(:unix_micro, 1, type: :int64, json_name: "unixMicro")
  field(:ticks, 2, type: :int32)
end

defmodule Livekit.Encryption do
  @moduledoc false

  use Protobuf, protoc_gen_elixir_version: "0.14.0", syntax: :proto3
end

defmodule Livekit.AudioTrackFeature do
  @moduledoc false

  use Protobuf, protoc_gen_elixir_version: "0.14.0", syntax: :proto3

  field(:tts, 1, type: :bool)
end

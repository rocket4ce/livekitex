defmodule Livekitex.Proto.Livekit.IngressInput do
  use Protobuf,
    enum: true,
    full_name: "livekit.IngressInput",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :RTMP_INPUT, 0
  field :WHIP_INPUT, 1
  field :URL_INPUT, 2
end

defmodule Livekitex.Proto.Livekit.IngressAudioEncodingPreset do
  use Protobuf,
    enum: true,
    full_name: "livekit.IngressAudioEncodingPreset",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :OPUS_STEREO_96KBPS, 0
  field :OPUS_MONO_64KBS, 1
end

defmodule Livekitex.Proto.Livekit.IngressVideoEncodingPreset do
  use Protobuf,
    enum: true,
    full_name: "livekit.IngressVideoEncodingPreset",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :H264_720P_30FPS_3_LAYERS, 0
  field :H264_1080P_30FPS_3_LAYERS, 1
  field :H264_540P_25FPS_2_LAYERS, 2
  field :H264_720P_30FPS_1_LAYER, 3
  field :H264_1080P_30FPS_1_LAYER, 4
  field :H264_720P_30FPS_3_LAYERS_HIGH_MOTION, 5
  field :H264_1080P_30FPS_3_LAYERS_HIGH_MOTION, 6
  field :H264_540P_25FPS_2_LAYERS_HIGH_MOTION, 7
  field :H264_720P_30FPS_1_LAYER_HIGH_MOTION, 8
  field :H264_1080P_30FPS_1_LAYER_HIGH_MOTION, 9
end

defmodule Livekitex.Proto.Livekit.IngressState.Status do
  use Protobuf,
    enum: true,
    full_name: "livekit.IngressState.Status",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :ENDPOINT_INACTIVE, 0
  field :ENDPOINT_BUFFERING, 1
  field :ENDPOINT_PUBLISHING, 2
  field :ENDPOINT_ERROR, 3
  field :ENDPOINT_COMPLETE, 4
end

defmodule Livekitex.Proto.Livekit.CreateIngressRequest do
  use Protobuf,
    full_name: "livekit.CreateIngressRequest",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :input_type, 1,
    type: Livekitex.Proto.Livekit.IngressInput,
    json_name: "inputType",
    enum: true

  field :url, 9, type: :string
  field :name, 2, type: :string
  field :room_name, 3, type: :string, json_name: "roomName"
  field :participant_identity, 4, type: :string, json_name: "participantIdentity"
  field :participant_name, 5, type: :string, json_name: "participantName", deprecated: false

  field :participant_metadata, 10,
    type: :string,
    json_name: "participantMetadata",
    deprecated: false

  field :bypass_transcoding, 8, type: :bool, json_name: "bypassTranscoding", deprecated: true

  field :enable_transcoding, 11,
    proto3_optional: true,
    type: :bool,
    json_name: "enableTranscoding"

  field :audio, 6, type: Livekitex.Proto.Livekit.IngressAudioOptions
  field :video, 7, type: Livekitex.Proto.Livekit.IngressVideoOptions
  field :enabled, 12, proto3_optional: true, type: :bool
end

defmodule Livekitex.Proto.Livekit.IngressAudioOptions do
  use Protobuf,
    full_name: "livekit.IngressAudioOptions",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  oneof :encoding_options, 0

  field :name, 1, type: :string
  field :source, 2, type: Livekitex.Proto.Livekit.TrackSource, enum: true
  field :preset, 3, type: Livekitex.Proto.Livekit.IngressAudioEncodingPreset, enum: true, oneof: 0
  field :options, 4, type: Livekitex.Proto.Livekit.IngressAudioEncodingOptions, oneof: 0
end

defmodule Livekitex.Proto.Livekit.IngressVideoOptions do
  use Protobuf,
    full_name: "livekit.IngressVideoOptions",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  oneof :encoding_options, 0

  field :name, 1, type: :string
  field :source, 2, type: Livekitex.Proto.Livekit.TrackSource, enum: true
  field :preset, 3, type: Livekitex.Proto.Livekit.IngressVideoEncodingPreset, enum: true, oneof: 0
  field :options, 4, type: Livekitex.Proto.Livekit.IngressVideoEncodingOptions, oneof: 0
end

defmodule Livekitex.Proto.Livekit.IngressAudioEncodingOptions do
  use Protobuf,
    full_name: "livekit.IngressAudioEncodingOptions",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :audio_codec, 1,
    type: Livekitex.Proto.Livekit.AudioCodec,
    json_name: "audioCodec",
    enum: true

  field :bitrate, 2, type: :uint32
  field :disable_dtx, 3, type: :bool, json_name: "disableDtx"
  field :channels, 4, type: :uint32
end

defmodule Livekitex.Proto.Livekit.IngressVideoEncodingOptions do
  use Protobuf,
    full_name: "livekit.IngressVideoEncodingOptions",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :video_codec, 1,
    type: Livekitex.Proto.Livekit.VideoCodec,
    json_name: "videoCodec",
    enum: true

  field :frame_rate, 2, type: :double, json_name: "frameRate"
  field :layers, 3, repeated: true, type: Livekitex.Proto.Livekit.VideoLayer
end

defmodule Livekitex.Proto.Livekit.IngressInfo do
  use Protobuf,
    full_name: "livekit.IngressInfo",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :ingress_id, 1, type: :string, json_name: "ingressId", deprecated: false
  field :name, 2, type: :string
  field :stream_key, 3, type: :string, json_name: "streamKey", deprecated: false
  field :url, 4, type: :string

  field :input_type, 5,
    type: Livekitex.Proto.Livekit.IngressInput,
    json_name: "inputType",
    enum: true

  field :bypass_transcoding, 13, type: :bool, json_name: "bypassTranscoding", deprecated: true

  field :enable_transcoding, 15,
    proto3_optional: true,
    type: :bool,
    json_name: "enableTranscoding"

  field :audio, 6, type: Livekitex.Proto.Livekit.IngressAudioOptions
  field :video, 7, type: Livekitex.Proto.Livekit.IngressVideoOptions
  field :room_name, 8, type: :string, json_name: "roomName"
  field :participant_identity, 9, type: :string, json_name: "participantIdentity"
  field :participant_name, 10, type: :string, json_name: "participantName", deprecated: false

  field :participant_metadata, 14,
    type: :string,
    json_name: "participantMetadata",
    deprecated: false

  field :reusable, 11, type: :bool
  field :state, 12, type: Livekitex.Proto.Livekit.IngressState
  field :enabled, 16, proto3_optional: true, type: :bool
end

defmodule Livekitex.Proto.Livekit.IngressState do
  use Protobuf,
    full_name: "livekit.IngressState",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :status, 1, type: Livekitex.Proto.Livekit.IngressState.Status, enum: true
  field :error, 2, type: :string
  field :video, 3, type: Livekitex.Proto.Livekit.InputVideoState
  field :audio, 4, type: Livekitex.Proto.Livekit.InputAudioState
  field :room_id, 5, type: :string, json_name: "roomId", deprecated: false
  field :started_at, 7, type: :int64, json_name: "startedAt"
  field :ended_at, 8, type: :int64, json_name: "endedAt"
  field :updated_at, 10, type: :int64, json_name: "updatedAt"
  field :resource_id, 9, type: :string, json_name: "resourceId", deprecated: false
  field :tracks, 6, repeated: true, type: Livekitex.Proto.Livekit.TrackInfo
end

defmodule Livekitex.Proto.Livekit.InputVideoState do
  use Protobuf,
    full_name: "livekit.InputVideoState",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :mime_type, 1, type: :string, json_name: "mimeType"
  field :average_bitrate, 2, type: :uint32, json_name: "averageBitrate"
  field :width, 3, type: :uint32
  field :height, 4, type: :uint32
  field :framerate, 5, type: :double
end

defmodule Livekitex.Proto.Livekit.InputAudioState do
  use Protobuf,
    full_name: "livekit.InputAudioState",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :mime_type, 1, type: :string, json_name: "mimeType"
  field :average_bitrate, 2, type: :uint32, json_name: "averageBitrate"
  field :channels, 3, type: :uint32
  field :sample_rate, 4, type: :uint32, json_name: "sampleRate"
end

defmodule Livekitex.Proto.Livekit.UpdateIngressRequest do
  use Protobuf,
    full_name: "livekit.UpdateIngressRequest",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :ingress_id, 1, type: :string, json_name: "ingressId", deprecated: false
  field :name, 2, type: :string
  field :room_name, 3, type: :string, json_name: "roomName"
  field :participant_identity, 4, type: :string, json_name: "participantIdentity"
  field :participant_name, 5, type: :string, json_name: "participantName", deprecated: false

  field :participant_metadata, 9,
    type: :string,
    json_name: "participantMetadata",
    deprecated: false

  field :bypass_transcoding, 8,
    proto3_optional: true,
    type: :bool,
    json_name: "bypassTranscoding",
    deprecated: true

  field :enable_transcoding, 10,
    proto3_optional: true,
    type: :bool,
    json_name: "enableTranscoding"

  field :audio, 6, type: Livekitex.Proto.Livekit.IngressAudioOptions
  field :video, 7, type: Livekitex.Proto.Livekit.IngressVideoOptions
  field :enabled, 11, proto3_optional: true, type: :bool
end

defmodule Livekitex.Proto.Livekit.ListIngressRequest do
  use Protobuf,
    full_name: "livekit.ListIngressRequest",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :page_token, 3, type: Livekitex.Proto.Livekit.TokenPagination, json_name: "pageToken"
  field :room_name, 1, type: :string, json_name: "roomName"
  field :ingress_id, 2, type: :string, json_name: "ingressId", deprecated: false
end

defmodule Livekitex.Proto.Livekit.ListIngressResponse do
  use Protobuf,
    full_name: "livekit.ListIngressResponse",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :next_page_token, 2,
    type: Livekitex.Proto.Livekit.TokenPagination,
    json_name: "nextPageToken"

  field :items, 1, repeated: true, type: Livekitex.Proto.Livekit.IngressInfo
end

defmodule Livekitex.Proto.Livekit.DeleteIngressRequest do
  use Protobuf,
    full_name: "livekit.DeleteIngressRequest",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :ingress_id, 1, type: :string, json_name: "ingressId", deprecated: false
end

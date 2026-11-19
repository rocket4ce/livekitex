defmodule Livekitex.Proto.Livekit.AudioChannel do
  use Protobuf,
    enum: true,
    full_name: "livekit.AudioChannel",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :AUDIO_CHANNEL_BOTH, 0
  field :AUDIO_CHANNEL_LEFT, 1
  field :AUDIO_CHANNEL_RIGHT, 2
end

defmodule Livekitex.Proto.Livekit.EncodingOptionsPreset do
  @moduledoc """
  --- Encoding ---
  """

  use Protobuf,
    enum: true,
    full_name: "livekit.EncodingOptionsPreset",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :H264_720P_30, 0
  field :H264_720P_60, 1
  field :H264_1080P_30, 2
  field :H264_1080P_60, 3
  field :PORTRAIT_H264_720P_30, 4
  field :PORTRAIT_H264_720P_60, 5
  field :PORTRAIT_H264_1080P_30, 6
  field :PORTRAIT_H264_1080P_60, 7
  field :PASSTHROUGH, 8
end

defmodule Livekitex.Proto.Livekit.EncodedFileType do
  use Protobuf,
    enum: true,
    full_name: "livekit.EncodedFileType",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :DEFAULT_FILETYPE, 0
  field :MP4, 1
  field :OGG, 2
  field :MP3, 3
  field :MCAP, 4
end

defmodule Livekitex.Proto.Livekit.StreamProtocol do
  use Protobuf,
    enum: true,
    full_name: "livekit.StreamProtocol",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :DEFAULT_PROTOCOL, 0
  field :RTMP, 1
  field :SRT, 2
  field :WEBSOCKET, 3
end

defmodule Livekitex.Proto.Livekit.SegmentedFileProtocol do
  use Protobuf,
    enum: true,
    full_name: "livekit.SegmentedFileProtocol",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :DEFAULT_SEGMENTED_FILE_PROTOCOL, 0
  field :HLS_PROTOCOL, 1
  field :HLS_FMP4_PROTOCOL, 2
end

defmodule Livekitex.Proto.Livekit.SegmentedFileSuffix do
  use Protobuf,
    enum: true,
    full_name: "livekit.SegmentedFileSuffix",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :INDEX, 0
  field :TIMESTAMP, 1
end

defmodule Livekitex.Proto.Livekit.ImageFileSuffix do
  use Protobuf,
    enum: true,
    full_name: "livekit.ImageFileSuffix",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :IMAGE_SUFFIX_INDEX, 0
  field :IMAGE_SUFFIX_TIMESTAMP, 1
  field :IMAGE_SUFFIX_NONE_OVERWRITE, 2
end

defmodule Livekitex.Proto.Livekit.EgressSourceType do
  use Protobuf,
    enum: true,
    full_name: "livekit.EgressSourceType",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :EGRESS_SOURCE_TYPE_WEB, 0
  field :EGRESS_SOURCE_TYPE_SDK, 1
end

defmodule Livekitex.Proto.Livekit.EgressStatus do
  use Protobuf,
    enum: true,
    full_name: "livekit.EgressStatus",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :EGRESS_STARTING, 0
  field :EGRESS_ACTIVE, 1
  field :EGRESS_ENDING, 2
  field :EGRESS_COMPLETE, 3
  field :EGRESS_FAILED, 4
  field :EGRESS_ABORTED, 5
  field :EGRESS_LIMIT_REACHED, 6
end

defmodule Livekitex.Proto.Livekit.AudioMixing do
  use Protobuf,
    enum: true,
    full_name: "livekit.AudioMixing",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :DEFAULT_MIXING, 0
  field :DUAL_CHANNEL_AGENT, 1
  field :DUAL_CHANNEL_ALTERNATE, 2
end

defmodule Livekitex.Proto.Livekit.StreamInfo.Status do
  use Protobuf,
    enum: true,
    full_name: "livekit.StreamInfo.Status",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :ACTIVE, 0
  field :FINISHED, 1
  field :FAILED, 2
end

defmodule Livekitex.Proto.Livekit.StartEgressRequest do
  @moduledoc """
  --- Core Request ---
  """

  use Protobuf,
    full_name: "livekit.StartEgressRequest",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  oneof :source, 0

  oneof :encoding, 1

  field :room_name, 1, type: :string, json_name: "roomName"
  field :template, 2, type: Livekitex.Proto.Livekit.TemplateSource, oneof: 0
  field :web, 3, type: Livekitex.Proto.Livekit.WebSource, oneof: 0
  field :media, 4, type: Livekitex.Proto.Livekit.MediaSource, oneof: 0
  field :preset, 5, type: Livekitex.Proto.Livekit.EncodingOptionsPreset, enum: true, oneof: 1
  field :advanced, 6, type: Livekitex.Proto.Livekit.EncodingOptions, oneof: 1
  field :outputs, 7, repeated: true, type: Livekitex.Proto.Livekit.Output
  field :storage, 8, type: Livekitex.Proto.Livekit.StorageConfig
  field :webhooks, 9, repeated: true, type: Livekitex.Proto.Livekit.WebhookConfig
end

defmodule Livekitex.Proto.Livekit.TemplateSource do
  @moduledoc """
  Room composite recording via layout template.
  Service generates token, constructs recorder URL, awaits start signal.
  --- Source Types ---
  """

  use Protobuf,
    full_name: "livekit.TemplateSource",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :layout, 1, type: :string
  field :audio_only, 2, type: :bool, json_name: "audioOnly"
  field :video_only, 3, type: :bool, json_name: "videoOnly"
  field :custom_base_url, 4, type: :string, json_name: "customBaseUrl"
end

defmodule Livekitex.Proto.Livekit.WebSource do
  @moduledoc """
  Record a custom URL via headless browser.
  """

  use Protobuf,
    full_name: "livekit.WebSource",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :url, 1, type: :string
  field :audio_only, 2, type: :bool, json_name: "audioOnly"
  field :video_only, 3, type: :bool, json_name: "videoOnly"
  field :await_start_signal, 4, type: :bool, json_name: "awaitStartSignal"
end

defmodule Livekitex.Proto.Livekit.MediaSource do
  @moduledoc """
  Capture tracks directly from a room via SDK.
  Unifies deprecated Participant, TrackComposite, and Track egress.
  """

  use Protobuf,
    full_name: "livekit.MediaSource",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  oneof :video, 0

  field :video_track_id, 1, type: :string, json_name: "videoTrackId", oneof: 0, deprecated: false

  field :participant_video, 2,
    type: Livekitex.Proto.Livekit.ParticipantVideo,
    json_name: "participantVideo",
    oneof: 0

  field :videos, 5, type: Livekitex.Proto.Livekit.VideoConfig, oneof: 0
  field :audio, 3, type: Livekitex.Proto.Livekit.AudioConfig
  field :data, 4, type: Livekitex.Proto.Livekit.DataConfig
end

defmodule Livekitex.Proto.Livekit.ParticipantVideo do
  @moduledoc """
  --- Video Configuration ---
  """

  use Protobuf,
    full_name: "livekit.ParticipantVideo",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :identity, 1, type: :string
  field :prefer_screen_share, 2, type: :bool, json_name: "preferScreenShare"
end

defmodule Livekitex.Proto.Livekit.VideoConfig do
  use Protobuf,
    full_name: "livekit.VideoConfig",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :capture_all, 1, type: :bool, json_name: "captureAll"
  field :selectors, 2, repeated: true, type: Livekitex.Proto.Livekit.VideoSelector
end

defmodule Livekitex.Proto.Livekit.VideoSelector do
  use Protobuf,
    full_name: "livekit.VideoSelector",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  oneof :match, 0

  field :track_id, 1, type: :string, json_name: "trackId", oneof: 0, deprecated: false
  field :participant_identity, 2, type: :string, json_name: "participantIdentity", oneof: 0
  field :track_name, 3, type: :string, json_name: "trackName"
  field :exclude, 4, type: :bool
end

defmodule Livekitex.Proto.Livekit.AudioConfig do
  @moduledoc """
  Unified audio selection and channel routing.
  Each route specifies both which audio to capture and which channel to output to.
  --- Audio Configuration ---
  """

  use Protobuf,
    full_name: "livekit.AudioConfig",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :capture_all, 1, type: :bool, json_name: "captureAll"
  field :routes, 2, repeated: true, type: Livekitex.Proto.Livekit.AudioRoute
end

defmodule Livekitex.Proto.Livekit.AudioRoute do
  use Protobuf,
    full_name: "livekit.AudioRoute",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  oneof :match, 0

  field :track_id, 1, type: :string, json_name: "trackId", oneof: 0, deprecated: false
  field :participant_identity, 2, type: :string, json_name: "participantIdentity", oneof: 0

  field :participant_kind, 3,
    type: Livekitex.Proto.Livekit.ParticipantInfo.Kind,
    json_name: "participantKind",
    enum: true,
    oneof: 0

  field :track_name, 5, type: :string, json_name: "trackName"
  field :exclude, 6, type: :bool
  field :channel, 4, type: Livekitex.Proto.Livekit.AudioChannel, enum: true
end

defmodule Livekitex.Proto.Livekit.DataConfig do
  @moduledoc """
  --- Data Track Configuration ---
  """

  use Protobuf,
    full_name: "livekit.DataConfig",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :capture_all, 1, type: :bool, json_name: "captureAll"
  field :selectors, 2, repeated: true, type: Livekitex.Proto.Livekit.DataSelector
end

defmodule Livekitex.Proto.Livekit.DataSelector do
  use Protobuf,
    full_name: "livekit.DataSelector",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  oneof :match, 0

  field :track_id, 1, type: :string, json_name: "trackId", oneof: 0, deprecated: false
  field :participant_identity, 2, type: :string, json_name: "participantIdentity", oneof: 0
  field :track_name, 3, type: :string, json_name: "trackName"
  field :exclude, 4, type: :bool
end

defmodule Livekitex.Proto.Livekit.EncodingOptions do
  use Protobuf,
    full_name: "livekit.EncodingOptions",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :width, 1, type: :int32
  field :height, 2, type: :int32
  field :depth, 3, type: :int32
  field :framerate, 4, type: :int32

  field :audio_codec, 5,
    type: Livekitex.Proto.Livekit.AudioCodec,
    json_name: "audioCodec",
    enum: true

  field :audio_bitrate, 6, type: :int32, json_name: "audioBitrate"
  field :audio_frequency, 7, type: :int32, json_name: "audioFrequency"

  field :video_codec, 8,
    type: Livekitex.Proto.Livekit.VideoCodec,
    json_name: "videoCodec",
    enum: true

  field :video_bitrate, 9, type: :int32, json_name: "videoBitrate"
  field :key_frame_interval, 10, type: :double, json_name: "keyFrameInterval"
  field :audio_quality, 11, type: :int32, json_name: "audioQuality", deprecated: true
  field :video_quality, 12, type: :int32, json_name: "videoQuality", deprecated: true
end

defmodule Livekitex.Proto.Livekit.Output do
  @moduledoc """
  --- Output Types ---
  """

  use Protobuf, full_name: "livekit.Output", protoc_gen_elixir_version: "0.17.1", syntax: :proto3

  oneof :config, 0

  field :file, 1, type: Livekitex.Proto.Livekit.FileOutput, oneof: 0
  field :stream, 2, type: Livekitex.Proto.Livekit.StreamOutput, oneof: 0
  field :segments, 3, type: Livekitex.Proto.Livekit.SegmentedFileOutput, oneof: 0
  field :images, 4, type: Livekitex.Proto.Livekit.ImageOutput, oneof: 0
  field :storage, 6, type: Livekitex.Proto.Livekit.StorageConfig
end

defmodule Livekitex.Proto.Livekit.FileOutput do
  @moduledoc """
  Unified file output — replaces v1 EncodedFileOutput and DirectFileOutput.
  Whether transcoded depends on encoding options on the request.
  """

  use Protobuf,
    full_name: "livekit.FileOutput",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :file_type, 1,
    type: Livekitex.Proto.Livekit.EncodedFileType,
    json_name: "fileType",
    enum: true

  field :filepath, 2, type: :string
  field :disable_manifest, 3, type: :bool, json_name: "disableManifest"
end

defmodule Livekitex.Proto.Livekit.StreamOutput do
  use Protobuf,
    full_name: "livekit.StreamOutput",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :protocol, 1, type: Livekitex.Proto.Livekit.StreamProtocol, enum: true
  field :urls, 2, repeated: true, type: :string
  field :destinations, 3, repeated: true, type: Livekitex.Proto.Livekit.StreamDestination
end

defmodule Livekitex.Proto.Livekit.StreamDestination do
  use Protobuf,
    full_name: "livekit.StreamDestination",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :id, 1, type: :string
  field :url, 2, type: :string
end

defmodule Livekitex.Proto.Livekit.SegmentedFileOutput do
  @moduledoc """
  Used to generate HLS segments or other kind of segmented output
  """

  use Protobuf,
    full_name: "livekit.SegmentedFileOutput",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  oneof :output, 0

  field :protocol, 1, type: Livekitex.Proto.Livekit.SegmentedFileProtocol, enum: true
  field :filename_prefix, 2, type: :string, json_name: "filenamePrefix"
  field :playlist_name, 3, type: :string, json_name: "playlistName"
  field :live_playlist_name, 11, type: :string, json_name: "livePlaylistName"
  field :segment_duration, 4, type: :uint32, json_name: "segmentDuration"

  field :filename_suffix, 10,
    type: Livekitex.Proto.Livekit.SegmentedFileSuffix,
    json_name: "filenameSuffix",
    enum: true

  field :disable_manifest, 8, type: :bool, json_name: "disableManifest"
  field :s3, 5, type: Livekitex.Proto.Livekit.S3Upload, oneof: 0
  field :gcp, 6, type: Livekitex.Proto.Livekit.GCPUpload, oneof: 0
  field :azure, 7, type: Livekitex.Proto.Livekit.AzureBlobUpload, oneof: 0
  field :aliOSS, 9, type: Livekitex.Proto.Livekit.AliOSSUpload, oneof: 0
end

defmodule Livekitex.Proto.Livekit.ImageOutput do
  @moduledoc """
  Capture images at a specified interval
  """

  use Protobuf,
    full_name: "livekit.ImageOutput",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  oneof :output, 0

  field :capture_interval, 1, type: :uint32, json_name: "captureInterval"
  field :width, 2, type: :int32
  field :height, 3, type: :int32
  field :filename_prefix, 4, type: :string, json_name: "filenamePrefix"

  field :filename_suffix, 5,
    type: Livekitex.Proto.Livekit.ImageFileSuffix,
    json_name: "filenameSuffix",
    enum: true

  field :image_codec, 6,
    type: Livekitex.Proto.Livekit.ImageCodec,
    json_name: "imageCodec",
    enum: true

  field :disable_manifest, 7, type: :bool, json_name: "disableManifest"
  field :s3, 8, type: Livekitex.Proto.Livekit.S3Upload, oneof: 0
  field :gcp, 9, type: Livekitex.Proto.Livekit.GCPUpload, oneof: 0
  field :azure, 10, type: Livekitex.Proto.Livekit.AzureBlobUpload, oneof: 0
  field :aliOSS, 11, type: Livekitex.Proto.Livekit.AliOSSUpload, oneof: 0
end

defmodule Livekitex.Proto.Livekit.StorageConfig do
  @moduledoc """
  --- Storage ---
  """

  use Protobuf,
    full_name: "livekit.StorageConfig",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  oneof :provider, 0

  field :s3, 1, type: Livekitex.Proto.Livekit.S3Upload, oneof: 0
  field :gcp, 2, type: Livekitex.Proto.Livekit.GCPUpload, oneof: 0
  field :azure, 3, type: Livekitex.Proto.Livekit.AzureBlobUpload, oneof: 0
  field :aliOSS, 4, type: Livekitex.Proto.Livekit.AliOSSUpload, oneof: 0
end

defmodule Livekitex.Proto.Livekit.S3Upload.MetadataEntry do
  use Protobuf,
    full_name: "livekit.S3Upload.MetadataEntry",
    map: true,
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :key, 1, type: :string
  field :value, 2, type: :string
end

defmodule Livekitex.Proto.Livekit.S3Upload do
  use Protobuf,
    full_name: "livekit.S3Upload",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :access_key, 1, type: :string, json_name: "accessKey", deprecated: false
  field :secret, 2, type: :string, deprecated: false
  field :session_token, 11, type: :string, json_name: "sessionToken", deprecated: false
  field :assume_role_arn, 12, type: :string, json_name: "assumeRoleArn", deprecated: false

  field :assume_role_external_id, 13,
    type: :string,
    json_name: "assumeRoleExternalId",
    deprecated: false

  field :region, 3, type: :string
  field :endpoint, 4, type: :string
  field :bucket, 5, type: :string
  field :force_path_style, 6, type: :bool, json_name: "forcePathStyle"

  field :metadata, 7,
    repeated: true,
    type: Livekitex.Proto.Livekit.S3Upload.MetadataEntry,
    map: true,
    deprecated: false

  field :tagging, 8, type: :string, deprecated: false
  field :content_disposition, 9, type: :string, json_name: "contentDisposition", deprecated: false
  field :proxy, 10, type: Livekitex.Proto.Livekit.ProxyConfig
end

defmodule Livekitex.Proto.Livekit.GCPUpload do
  use Protobuf,
    full_name: "livekit.GCPUpload",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :credentials, 1, type: :string, deprecated: false
  field :bucket, 2, type: :string
  field :proxy, 3, type: Livekitex.Proto.Livekit.ProxyConfig
end

defmodule Livekitex.Proto.Livekit.AzureBlobUpload do
  use Protobuf,
    full_name: "livekit.AzureBlobUpload",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :account_name, 1, type: :string, json_name: "accountName", deprecated: false
  field :account_key, 2, type: :string, json_name: "accountKey", deprecated: false
  field :container_name, 3, type: :string, json_name: "containerName"
end

defmodule Livekitex.Proto.Livekit.AliOSSUpload do
  use Protobuf,
    full_name: "livekit.AliOSSUpload",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :access_key, 1, type: :string, json_name: "accessKey", deprecated: false
  field :secret, 2, type: :string, deprecated: false
  field :region, 3, type: :string
  field :endpoint, 4, type: :string
  field :bucket, 5, type: :string
end

defmodule Livekitex.Proto.Livekit.ProxyConfig do
  use Protobuf,
    full_name: "livekit.ProxyConfig",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :url, 1, type: :string
  field :username, 2, type: :string
  field :password, 3, type: :string, deprecated: false
end

defmodule Livekitex.Proto.Livekit.ListEgressRequest do
  @moduledoc """
  --- Control RPCs ---
  """

  use Protobuf,
    full_name: "livekit.ListEgressRequest",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :room_name, 1, type: :string, json_name: "roomName"
  field :egress_id, 2, type: :string, json_name: "egressId", deprecated: false
  field :active, 3, type: :bool
  field :page_token, 4, type: Livekitex.Proto.Livekit.TokenPagination, json_name: "pageToken"
end

defmodule Livekitex.Proto.Livekit.ListEgressResponse do
  use Protobuf,
    full_name: "livekit.ListEgressResponse",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :items, 1, repeated: true, type: Livekitex.Proto.Livekit.EgressInfo

  field :next_page_token, 2,
    type: Livekitex.Proto.Livekit.TokenPagination,
    json_name: "nextPageToken"
end

defmodule Livekitex.Proto.Livekit.StopEgressRequest do
  use Protobuf,
    full_name: "livekit.StopEgressRequest",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :egress_id, 1, type: :string, json_name: "egressId", deprecated: false
end

defmodule Livekitex.Proto.Livekit.EgressInfo do
  @moduledoc """
  --- Egress Info ---
  """

  use Protobuf,
    full_name: "livekit.EgressInfo",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  oneof :request, 0

  oneof :result, 1

  field :egress_id, 1, type: :string, json_name: "egressId", deprecated: false
  field :room_id, 2, type: :string, json_name: "roomId", deprecated: false
  field :room_name, 13, type: :string, json_name: "roomName"

  field :source_type, 26,
    type: Livekitex.Proto.Livekit.EgressSourceType,
    json_name: "sourceType",
    enum: true

  field :status, 3, type: Livekitex.Proto.Livekit.EgressStatus, enum: true
  field :started_at, 10, type: :int64, json_name: "startedAt"
  field :ended_at, 11, type: :int64, json_name: "endedAt"
  field :updated_at, 18, type: :int64, json_name: "updatedAt"
  field :egress, 29, type: Livekitex.Proto.Livekit.StartEgressRequest, oneof: 0
  field :replay, 30, type: Livekitex.Proto.Livekit.ExportReplayRequest, oneof: 0

  field :room_composite, 4,
    type: Livekitex.Proto.Livekit.RoomCompositeEgressRequest,
    json_name: "roomComposite",
    oneof: 0

  field :web, 14, type: Livekitex.Proto.Livekit.WebEgressRequest, oneof: 0
  field :participant, 19, type: Livekitex.Proto.Livekit.ParticipantEgressRequest, oneof: 0

  field :track_composite, 5,
    type: Livekitex.Proto.Livekit.TrackCompositeEgressRequest,
    json_name: "trackComposite",
    oneof: 0

  field :track, 6, type: Livekitex.Proto.Livekit.TrackEgressRequest, oneof: 0

  field :stream_results, 15,
    repeated: true,
    type: Livekitex.Proto.Livekit.StreamInfo,
    json_name: "streamResults"

  field :file_results, 16,
    repeated: true,
    type: Livekitex.Proto.Livekit.FileInfo,
    json_name: "fileResults"

  field :segment_results, 17,
    repeated: true,
    type: Livekitex.Proto.Livekit.SegmentsInfo,
    json_name: "segmentResults"

  field :image_results, 20,
    repeated: true,
    type: Livekitex.Proto.Livekit.ImagesInfo,
    json_name: "imageResults"

  field :error, 9, type: :string
  field :error_code, 22, type: :int32, json_name: "errorCode"
  field :details, 21, type: :string
  field :manifest_location, 23, type: :string, json_name: "manifestLocation"
  field :backup_storage_used, 25, type: :bool, json_name: "backupStorageUsed"
  field :retry_count, 27, type: :int32, json_name: "retryCount"
  field :stream, 7, type: Livekitex.Proto.Livekit.StreamInfoList, oneof: 1, deprecated: true
  field :file, 8, type: Livekitex.Proto.Livekit.FileInfo, oneof: 1, deprecated: true
  field :segments, 12, type: Livekitex.Proto.Livekit.SegmentsInfo, oneof: 1, deprecated: true
end

defmodule Livekitex.Proto.Livekit.StreamInfo do
  use Protobuf,
    full_name: "livekit.StreamInfo",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :url, 1, type: :string
  field :started_at, 2, type: :int64, json_name: "startedAt"
  field :ended_at, 3, type: :int64, json_name: "endedAt"
  field :duration, 4, type: :int64
  field :status, 5, type: Livekitex.Proto.Livekit.StreamInfo.Status, enum: true
  field :error, 6, type: :string
  field :last_retry_at, 7, type: :int64, json_name: "lastRetryAt"
  field :retries, 8, type: :uint32
  field :id, 9, type: :string
end

defmodule Livekitex.Proto.Livekit.FileInfo do
  use Protobuf,
    full_name: "livekit.FileInfo",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :filename, 1, type: :string
  field :started_at, 2, type: :int64, json_name: "startedAt"
  field :ended_at, 3, type: :int64, json_name: "endedAt"
  field :duration, 6, type: :int64
  field :size, 4, type: :int64
  field :location, 5, type: :string
end

defmodule Livekitex.Proto.Livekit.SegmentsInfo do
  use Protobuf,
    full_name: "livekit.SegmentsInfo",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :playlist_name, 1, type: :string, json_name: "playlistName"
  field :live_playlist_name, 8, type: :string, json_name: "livePlaylistName"
  field :duration, 2, type: :int64
  field :size, 3, type: :int64
  field :playlist_location, 4, type: :string, json_name: "playlistLocation"
  field :live_playlist_location, 9, type: :string, json_name: "livePlaylistLocation"
  field :segment_count, 5, type: :int64, json_name: "segmentCount"
  field :started_at, 6, type: :int64, json_name: "startedAt"
  field :ended_at, 7, type: :int64, json_name: "endedAt"
end

defmodule Livekitex.Proto.Livekit.ImagesInfo do
  use Protobuf,
    full_name: "livekit.ImagesInfo",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :filename_prefix, 4, type: :string, json_name: "filenamePrefix"
  field :image_count, 1, type: :int64, json_name: "imageCount"
  field :started_at, 2, type: :int64, json_name: "startedAt"
  field :ended_at, 3, type: :int64, json_name: "endedAt"
end

defmodule Livekitex.Proto.Livekit.AutoParticipantEgress do
  @moduledoc """
  --- Auto Egress ---
  """

  use Protobuf,
    full_name: "livekit.AutoParticipantEgress",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  oneof :options, 0

  field :preset, 1, type: Livekitex.Proto.Livekit.EncodingOptionsPreset, enum: true, oneof: 0
  field :advanced, 2, type: Livekitex.Proto.Livekit.EncodingOptions, oneof: 0

  field :file_outputs, 3,
    repeated: true,
    type: Livekitex.Proto.Livekit.EncodedFileOutput,
    json_name: "fileOutputs"

  field :segment_outputs, 4,
    repeated: true,
    type: Livekitex.Proto.Livekit.SegmentedFileOutput,
    json_name: "segmentOutputs"
end

defmodule Livekitex.Proto.Livekit.AutoTrackEgress do
  use Protobuf,
    full_name: "livekit.AutoTrackEgress",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  oneof :output, 0

  field :filepath, 1, type: :string
  field :disable_manifest, 5, type: :bool, json_name: "disableManifest"
  field :s3, 2, type: Livekitex.Proto.Livekit.S3Upload, oneof: 0
  field :gcp, 3, type: Livekitex.Proto.Livekit.GCPUpload, oneof: 0
  field :azure, 4, type: Livekitex.Proto.Livekit.AzureBlobUpload, oneof: 0
  field :aliOSS, 6, type: Livekitex.Proto.Livekit.AliOSSUpload, oneof: 0
end

defmodule Livekitex.Proto.Livekit.ExportReplayRequest do
  @moduledoc """
  --- Replay Export (message only — RPC defined in cloud_replay.proto) ---
  """

  use Protobuf,
    full_name: "livekit.ExportReplayRequest",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  oneof :source, 0

  oneof :encoding, 1

  field :replay_id, 1, type: :string, json_name: "replayId", deprecated: false
  field :start_offset_ms, 2, type: :int64, json_name: "startOffsetMs"
  field :end_offset_ms, 3, type: :int64, json_name: "endOffsetMs"
  field :template, 4, type: Livekitex.Proto.Livekit.TemplateSource, oneof: 0
  field :web, 5, type: Livekitex.Proto.Livekit.WebSource, oneof: 0
  field :media, 6, type: Livekitex.Proto.Livekit.MediaSource, oneof: 0
  field :preset, 7, type: Livekitex.Proto.Livekit.EncodingOptionsPreset, enum: true, oneof: 1
  field :advanced, 8, type: Livekitex.Proto.Livekit.EncodingOptions, oneof: 1
  field :outputs, 9, repeated: true, type: Livekitex.Proto.Livekit.Output
  field :storage, 10, type: Livekitex.Proto.Livekit.StorageConfig
  field :webhooks, 11, repeated: true, type: Livekitex.Proto.Livekit.WebhookConfig
end

defmodule Livekitex.Proto.Livekit.RoomCompositeEgressRequest do
  @moduledoc """
  TODO: deprecate --- V1 ---
  """

  use Protobuf,
    full_name: "livekit.RoomCompositeEgressRequest",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  oneof :output, 0

  oneof :options, 1

  field :room_name, 1, type: :string, json_name: "roomName"
  field :layout, 2, type: :string
  field :audio_only, 3, type: :bool, json_name: "audioOnly"

  field :audio_mixing, 15,
    type: Livekitex.Proto.Livekit.AudioMixing,
    json_name: "audioMixing",
    enum: true

  field :video_only, 4, type: :bool, json_name: "videoOnly"
  field :custom_base_url, 5, type: :string, json_name: "customBaseUrl"
  field :file, 6, type: Livekitex.Proto.Livekit.EncodedFileOutput, oneof: 0, deprecated: true
  field :stream, 7, type: Livekitex.Proto.Livekit.StreamOutput, oneof: 0, deprecated: true

  field :segments, 10,
    type: Livekitex.Proto.Livekit.SegmentedFileOutput,
    oneof: 0,
    deprecated: true

  field :preset, 8, type: Livekitex.Proto.Livekit.EncodingOptionsPreset, enum: true, oneof: 1
  field :advanced, 9, type: Livekitex.Proto.Livekit.EncodingOptions, oneof: 1

  field :file_outputs, 11,
    repeated: true,
    type: Livekitex.Proto.Livekit.EncodedFileOutput,
    json_name: "fileOutputs"

  field :stream_outputs, 12,
    repeated: true,
    type: Livekitex.Proto.Livekit.StreamOutput,
    json_name: "streamOutputs"

  field :segment_outputs, 13,
    repeated: true,
    type: Livekitex.Proto.Livekit.SegmentedFileOutput,
    json_name: "segmentOutputs"

  field :image_outputs, 14,
    repeated: true,
    type: Livekitex.Proto.Livekit.ImageOutput,
    json_name: "imageOutputs"

  field :webhooks, 16, repeated: true, type: Livekitex.Proto.Livekit.WebhookConfig
end

defmodule Livekitex.Proto.Livekit.WebEgressRequest do
  use Protobuf,
    full_name: "livekit.WebEgressRequest",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  oneof :output, 0

  oneof :options, 1

  field :url, 1, type: :string
  field :audio_only, 2, type: :bool, json_name: "audioOnly"
  field :video_only, 3, type: :bool, json_name: "videoOnly"
  field :await_start_signal, 12, type: :bool, json_name: "awaitStartSignal"
  field :file, 4, type: Livekitex.Proto.Livekit.EncodedFileOutput, oneof: 0, deprecated: true
  field :stream, 5, type: Livekitex.Proto.Livekit.StreamOutput, oneof: 0, deprecated: true

  field :segments, 6,
    type: Livekitex.Proto.Livekit.SegmentedFileOutput,
    oneof: 0,
    deprecated: true

  field :preset, 7, type: Livekitex.Proto.Livekit.EncodingOptionsPreset, enum: true, oneof: 1
  field :advanced, 8, type: Livekitex.Proto.Livekit.EncodingOptions, oneof: 1

  field :file_outputs, 9,
    repeated: true,
    type: Livekitex.Proto.Livekit.EncodedFileOutput,
    json_name: "fileOutputs"

  field :stream_outputs, 10,
    repeated: true,
    type: Livekitex.Proto.Livekit.StreamOutput,
    json_name: "streamOutputs"

  field :segment_outputs, 11,
    repeated: true,
    type: Livekitex.Proto.Livekit.SegmentedFileOutput,
    json_name: "segmentOutputs"

  field :image_outputs, 13,
    repeated: true,
    type: Livekitex.Proto.Livekit.ImageOutput,
    json_name: "imageOutputs"

  field :webhooks, 14, repeated: true, type: Livekitex.Proto.Livekit.WebhookConfig
end

defmodule Livekitex.Proto.Livekit.ParticipantEgressRequest do
  use Protobuf,
    full_name: "livekit.ParticipantEgressRequest",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  oneof :options, 0

  field :room_name, 1, type: :string, json_name: "roomName"
  field :identity, 2, type: :string
  field :screen_share, 3, type: :bool, json_name: "screenShare"
  field :preset, 4, type: Livekitex.Proto.Livekit.EncodingOptionsPreset, enum: true, oneof: 0
  field :advanced, 5, type: Livekitex.Proto.Livekit.EncodingOptions, oneof: 0

  field :file_outputs, 6,
    repeated: true,
    type: Livekitex.Proto.Livekit.EncodedFileOutput,
    json_name: "fileOutputs"

  field :stream_outputs, 7,
    repeated: true,
    type: Livekitex.Proto.Livekit.StreamOutput,
    json_name: "streamOutputs"

  field :segment_outputs, 8,
    repeated: true,
    type: Livekitex.Proto.Livekit.SegmentedFileOutput,
    json_name: "segmentOutputs"

  field :image_outputs, 9,
    repeated: true,
    type: Livekitex.Proto.Livekit.ImageOutput,
    json_name: "imageOutputs"

  field :webhooks, 10, repeated: true, type: Livekitex.Proto.Livekit.WebhookConfig
end

defmodule Livekitex.Proto.Livekit.TrackCompositeEgressRequest do
  use Protobuf,
    full_name: "livekit.TrackCompositeEgressRequest",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  oneof :output, 0

  oneof :options, 1

  field :room_name, 1, type: :string, json_name: "roomName"
  field :audio_track_id, 2, type: :string, json_name: "audioTrackId", deprecated: false
  field :video_track_id, 3, type: :string, json_name: "videoTrackId", deprecated: false
  field :file, 4, type: Livekitex.Proto.Livekit.EncodedFileOutput, oneof: 0, deprecated: true
  field :stream, 5, type: Livekitex.Proto.Livekit.StreamOutput, oneof: 0, deprecated: true

  field :segments, 8,
    type: Livekitex.Proto.Livekit.SegmentedFileOutput,
    oneof: 0,
    deprecated: true

  field :preset, 6, type: Livekitex.Proto.Livekit.EncodingOptionsPreset, enum: true, oneof: 1
  field :advanced, 7, type: Livekitex.Proto.Livekit.EncodingOptions, oneof: 1

  field :file_outputs, 11,
    repeated: true,
    type: Livekitex.Proto.Livekit.EncodedFileOutput,
    json_name: "fileOutputs"

  field :stream_outputs, 12,
    repeated: true,
    type: Livekitex.Proto.Livekit.StreamOutput,
    json_name: "streamOutputs"

  field :segment_outputs, 13,
    repeated: true,
    type: Livekitex.Proto.Livekit.SegmentedFileOutput,
    json_name: "segmentOutputs"

  field :image_outputs, 14,
    repeated: true,
    type: Livekitex.Proto.Livekit.ImageOutput,
    json_name: "imageOutputs"

  field :webhooks, 15, repeated: true, type: Livekitex.Proto.Livekit.WebhookConfig
end

defmodule Livekitex.Proto.Livekit.TrackEgressRequest do
  use Protobuf,
    full_name: "livekit.TrackEgressRequest",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  oneof :output, 0

  field :room_name, 1, type: :string, json_name: "roomName"
  field :track_id, 2, type: :string, json_name: "trackId", deprecated: false
  field :file, 3, type: Livekitex.Proto.Livekit.DirectFileOutput, oneof: 0
  field :websocket_url, 4, type: :string, json_name: "websocketUrl", oneof: 0
  field :webhooks, 5, repeated: true, type: Livekitex.Proto.Livekit.WebhookConfig
end

defmodule Livekitex.Proto.Livekit.DirectFileOutput do
  use Protobuf,
    full_name: "livekit.DirectFileOutput",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  oneof :output, 0

  field :filepath, 1, type: :string
  field :disable_manifest, 5, type: :bool, json_name: "disableManifest"
  field :s3, 2, type: Livekitex.Proto.Livekit.S3Upload, oneof: 0
  field :gcp, 3, type: Livekitex.Proto.Livekit.GCPUpload, oneof: 0
  field :azure, 4, type: Livekitex.Proto.Livekit.AzureBlobUpload, oneof: 0
  field :aliOSS, 6, type: Livekitex.Proto.Livekit.AliOSSUpload, oneof: 0
end

defmodule Livekitex.Proto.Livekit.EncodedFileOutput do
  use Protobuf,
    full_name: "livekit.EncodedFileOutput",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  oneof :output, 0

  field :file_type, 1,
    type: Livekitex.Proto.Livekit.EncodedFileType,
    json_name: "fileType",
    enum: true

  field :filepath, 2, type: :string
  field :disable_manifest, 6, type: :bool, json_name: "disableManifest"
  field :s3, 3, type: Livekitex.Proto.Livekit.S3Upload, oneof: 0
  field :gcp, 4, type: Livekitex.Proto.Livekit.GCPUpload, oneof: 0
  field :azure, 5, type: Livekitex.Proto.Livekit.AzureBlobUpload, oneof: 0
  field :aliOSS, 7, type: Livekitex.Proto.Livekit.AliOSSUpload, oneof: 0
end

defmodule Livekitex.Proto.Livekit.UpdateLayoutRequest do
  use Protobuf,
    full_name: "livekit.UpdateLayoutRequest",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :egress_id, 1, type: :string, json_name: "egressId", deprecated: false
  field :layout, 2, type: :string
end

defmodule Livekitex.Proto.Livekit.UpdateStreamRequest do
  use Protobuf,
    full_name: "livekit.UpdateStreamRequest",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :egress_id, 1, type: :string, json_name: "egressId", deprecated: false
  field :add_output_urls, 2, repeated: true, type: :string, json_name: "addOutputUrls"
  field :remove_output_urls, 3, repeated: true, type: :string, json_name: "removeOutputUrls"

  field :add_destinations, 4,
    repeated: true,
    type: Livekitex.Proto.Livekit.StreamDestination,
    json_name: "addDestinations"
end

defmodule Livekitex.Proto.Livekit.StreamInfoList do
  use Protobuf,
    full_name: "livekit.StreamInfoList",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :info, 1, repeated: true, type: Livekitex.Proto.Livekit.StreamInfo
end

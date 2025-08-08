defmodule Livekit.EgressStatus do
  @moduledoc false

  use Protobuf, enum: true, protoc_gen_elixir_version: "0.14.0", syntax: :proto3

  field(:EGRESS_STARTING, 0)
  field(:EGRESS_ACTIVE, 1)
  field(:EGRESS_ENDING, 2)
  field(:EGRESS_COMPLETE, 3)
  field(:EGRESS_FAILED, 4)
  field(:EGRESS_ABORTED, 5)
  field(:EGRESS_LIMIT_REACHED, 6)
end

defmodule Livekit.SegmentedFileProtocol do
  @moduledoc false

  use Protobuf, enum: true, protoc_gen_elixir_version: "0.14.0", syntax: :proto3

  field(:DEFAULT_SEGMENTED_FILE_PROTOCOL, 0)
  field(:HLS_PROTOCOL, 1)
end

defmodule Livekit.EncodedFileType do
  @moduledoc false

  use Protobuf, enum: true, protoc_gen_elixir_version: "0.14.0", syntax: :proto3

  field(:DEFAULT_FILETYPE, 0)
  field(:MP4, 1)
  field(:OGG, 2)
end

defmodule Livekit.StreamProtocol do
  @moduledoc false

  use Protobuf, enum: true, protoc_gen_elixir_version: "0.14.0", syntax: :proto3

  field(:DEFAULT_PROTOCOL, 0)
  field(:RTMP, 1)
  field(:SRT, 2)
end

defmodule Livekit.ImageCodec do
  @moduledoc false

  use Protobuf, enum: true, protoc_gen_elixir_version: "0.14.0", syntax: :proto3

  field(:IC_DEFAULT, 0)
  field(:IC_JPEG, 1)
end

defmodule Livekit.EncodingOptionsPreset do
  @moduledoc false

  use Protobuf, enum: true, protoc_gen_elixir_version: "0.14.0", syntax: :proto3

  field(:H264_720P_30, 0)
  field(:H264_720P_60, 1)
  field(:H264_1080P_30, 2)
  field(:H264_1080P_60, 3)
  field(:PORTRAIT_H264_720P_30, 4)
  field(:PORTRAIT_H264_720P_60, 5)
  field(:PORTRAIT_H264_1080P_30, 6)
  field(:PORTRAIT_H264_1080P_60, 7)
end

defmodule Livekit.AudioCodec do
  @moduledoc false

  use Protobuf, enum: true, protoc_gen_elixir_version: "0.14.0", syntax: :proto3

  field(:DEFAULT_AC, 0)
  field(:OPUS, 1)
  field(:AAC, 2)
end

defmodule Livekit.VideoCodec do
  @moduledoc false

  use Protobuf, enum: true, protoc_gen_elixir_version: "0.14.0", syntax: :proto3

  field(:DEFAULT_VC, 0)
  field(:H264_BASELINE_CODEC, 1)
  field(:H264_MAIN_CODEC, 2)
  field(:H264_HIGH_CODEC, 3)
end

defmodule Livekit.H264Profile do
  @moduledoc false

  use Protobuf, enum: true, protoc_gen_elixir_version: "0.14.0", syntax: :proto3

  field(:H264_BASELINE_PROFILE, 0)
  field(:H264_MAIN_PROFILE, 1)
  field(:H264_HIGH_PROFILE, 2)
end

defmodule Livekit.StreamInfo.Status do
  @moduledoc false

  use Protobuf, enum: true, protoc_gen_elixir_version: "0.14.0", syntax: :proto3

  field(:ACTIVE, 0)
  field(:FINISHED, 1)
  field(:FAILED, 2)
end

defmodule Livekit.RoomCompositeEgressRequest do
  @moduledoc false

  use Protobuf, protoc_gen_elixir_version: "0.14.0", syntax: :proto3

  oneof(:options, 0)

  field(:room_name, 1, type: :string, json_name: "roomName")
  field(:layout, 2, type: :string)
  field(:audio_only, 3, type: :bool, json_name: "audioOnly")
  field(:video_only, 4, type: :bool, json_name: "videoOnly")
  field(:custom_base_url, 5, type: :string, json_name: "customBaseUrl")
  field(:file, 6, type: Livekit.EncodedFileOutput)
  field(:stream, 7, type: Livekit.StreamOutput)

  field(:file_outputs, 11,
    repeated: true,
    type: Livekit.EncodedFileOutput,
    json_name: "fileOutputs"
  )

  field(:stream_outputs, 12,
    repeated: true,
    type: Livekit.StreamOutput,
    json_name: "streamOutputs"
  )

  field(:segment_outputs, 13,
    repeated: true,
    type: Livekit.SegmentedFileOutput,
    json_name: "segmentOutputs"
  )

  field(:image_outputs, 14, repeated: true, type: Livekit.ImageOutput, json_name: "imageOutputs")
  field(:preset, 8, type: Livekit.EncodingOptionsPreset, enum: true, oneof: 0)
  field(:advanced, 9, type: Livekit.EncodingOptions, oneof: 0)
  field(:segments, 10, type: Livekit.SegmentedFileOutput, deprecated: true)
end

defmodule Livekit.TrackCompositeEgressRequest do
  @moduledoc false

  use Protobuf, protoc_gen_elixir_version: "0.14.0", syntax: :proto3

  oneof(:options, 0)

  field(:room_name, 1, type: :string, json_name: "roomName")
  field(:audio_track_id, 2, type: :string, json_name: "audioTrackId")
  field(:video_track_id, 3, type: :string, json_name: "videoTrackId")
  field(:file, 4, type: Livekit.EncodedFileOutput)
  field(:stream, 5, type: Livekit.StreamOutput)

  field(:file_outputs, 11,
    repeated: true,
    type: Livekit.EncodedFileOutput,
    json_name: "fileOutputs"
  )

  field(:stream_outputs, 12,
    repeated: true,
    type: Livekit.StreamOutput,
    json_name: "streamOutputs"
  )

  field(:segment_outputs, 13,
    repeated: true,
    type: Livekit.SegmentedFileOutput,
    json_name: "segmentOutputs"
  )

  field(:image_outputs, 14, repeated: true, type: Livekit.ImageOutput, json_name: "imageOutputs")
  field(:preset, 6, type: Livekit.EncodingOptionsPreset, enum: true, oneof: 0)
  field(:advanced, 7, type: Livekit.EncodingOptions, oneof: 0)
  field(:segments, 8, type: Livekit.SegmentedFileOutput, deprecated: true)
end

defmodule Livekit.TrackEgressRequest do
  @moduledoc false

  use Protobuf, protoc_gen_elixir_version: "0.14.0", syntax: :proto3

  oneof(:output, 0)

  field(:room_name, 1, type: :string, json_name: "roomName")
  field(:track_id, 2, type: :string, json_name: "trackId")
  field(:file, 3, type: Livekit.DirectFileOutput, oneof: 0)
  field(:websocket_url, 4, type: :string, json_name: "websocketUrl", oneof: 0)
end

defmodule Livekit.ParticipantEgressRequest do
  @moduledoc false

  use Protobuf, protoc_gen_elixir_version: "0.14.0", syntax: :proto3

  oneof(:options, 0)

  field(:room_name, 1, type: :string, json_name: "roomName")
  field(:identity, 2, type: :string)
  field(:screen_share, 3, type: :bool, json_name: "screenShare")
  field(:file, 4, type: Livekit.EncodedFileOutput)
  field(:stream, 5, type: Livekit.StreamOutput)

  field(:file_outputs, 11,
    repeated: true,
    type: Livekit.EncodedFileOutput,
    json_name: "fileOutputs"
  )

  field(:stream_outputs, 12,
    repeated: true,
    type: Livekit.StreamOutput,
    json_name: "streamOutputs"
  )

  field(:segment_outputs, 13,
    repeated: true,
    type: Livekit.SegmentedFileOutput,
    json_name: "segmentOutputs"
  )

  field(:image_outputs, 14, repeated: true, type: Livekit.ImageOutput, json_name: "imageOutputs")
  field(:preset, 6, type: Livekit.EncodingOptionsPreset, enum: true, oneof: 0)
  field(:advanced, 7, type: Livekit.EncodingOptions, oneof: 0)
  field(:segments, 8, type: Livekit.SegmentedFileOutput, deprecated: true)
end

defmodule Livekit.WebEgressRequest do
  @moduledoc false

  use Protobuf, protoc_gen_elixir_version: "0.14.0", syntax: :proto3

  oneof(:options, 0)

  field(:url, 1, type: :string)
  field(:audio_only, 2, type: :bool, json_name: "audioOnly")
  field(:video_only, 3, type: :bool, json_name: "videoOnly")
  field(:await_start_signal, 4, type: :bool, json_name: "awaitStartSignal")
  field(:file, 5, type: Livekit.EncodedFileOutput)
  field(:stream, 6, type: Livekit.StreamOutput)

  field(:file_outputs, 11,
    repeated: true,
    type: Livekit.EncodedFileOutput,
    json_name: "fileOutputs"
  )

  field(:stream_outputs, 12,
    repeated: true,
    type: Livekit.StreamOutput,
    json_name: "streamOutputs"
  )

  field(:segment_outputs, 13,
    repeated: true,
    type: Livekit.SegmentedFileOutput,
    json_name: "segmentOutputs"
  )

  field(:image_outputs, 14, repeated: true, type: Livekit.ImageOutput, json_name: "imageOutputs")
  field(:preset, 7, type: Livekit.EncodingOptionsPreset, enum: true, oneof: 0)
  field(:advanced, 8, type: Livekit.EncodingOptions, oneof: 0)
  field(:segments, 9, type: Livekit.SegmentedFileOutput, deprecated: true)
end

defmodule Livekit.UpdateLayoutRequest do
  @moduledoc false

  use Protobuf, protoc_gen_elixir_version: "0.14.0", syntax: :proto3

  field(:egress_id, 1, type: :string, json_name: "egressId")
  field(:layout, 2, type: :string)
end

defmodule Livekit.UpdateStreamRequest do
  @moduledoc false

  use Protobuf, protoc_gen_elixir_version: "0.14.0", syntax: :proto3

  field(:egress_id, 1, type: :string, json_name: "egressId")
  field(:add_output_urls, 2, repeated: true, type: :string, json_name: "addOutputUrls")
  field(:remove_output_urls, 3, repeated: true, type: :string, json_name: "removeOutputUrls")
end

defmodule Livekit.ListEgressRequest do
  @moduledoc false

  use Protobuf, protoc_gen_elixir_version: "0.14.0", syntax: :proto3

  field(:room_name, 1, type: :string, json_name: "roomName")
  field(:egress_id, 2, type: :string, json_name: "egressId")
  field(:active, 3, type: :bool)
end

defmodule Livekit.ListEgressResponse do
  @moduledoc false

  use Protobuf, protoc_gen_elixir_version: "0.14.0", syntax: :proto3

  field(:items, 1, repeated: true, type: Livekit.EgressInfo)
end

defmodule Livekit.StopEgressRequest do
  @moduledoc false

  use Protobuf, protoc_gen_elixir_version: "0.14.0", syntax: :proto3

  field(:egress_id, 1, type: :string, json_name: "egressId")
end

defmodule Livekit.EgressInfo do
  @moduledoc false

  use Protobuf, protoc_gen_elixir_version: "0.14.0", syntax: :proto3

  field(:egress_id, 1, type: :string, json_name: "egressId")
  field(:room_id, 2, type: :string, json_name: "roomId")
  field(:room_name, 13, type: :string, json_name: "roomName")
  field(:status, 3, type: Livekit.EgressStatus, enum: true)
  field(:started_at, 10, type: :int64, json_name: "startedAt")
  field(:ended_at, 11, type: :int64, json_name: "endedAt")
  field(:updated_at, 18, type: :int64, json_name: "updatedAt")
  field(:details, 21, type: :string)
  field(:error, 9, type: :string)
  field(:room_composite, 4, type: Livekit.RoomCompositeEgressRequest, json_name: "roomComposite")

  field(:track_composite, 5,
    type: Livekit.TrackCompositeEgressRequest,
    json_name: "trackComposite"
  )

  field(:track, 6, type: Livekit.TrackEgressRequest)
  field(:web, 7, type: Livekit.WebEgressRequest)
  field(:participant, 19, type: Livekit.ParticipantEgressRequest)
  field(:stream_results, 8, repeated: true, type: Livekit.StreamInfo, json_name: "streamResults")
  field(:file_results, 12, repeated: true, type: Livekit.FileInfo, json_name: "fileResults")

  field(:segment_results, 16,
    repeated: true,
    type: Livekit.SegmentedFileInfo,
    json_name: "segmentResults"
  )

  field(:image_results, 17, repeated: true, type: Livekit.ImagesInfo, json_name: "imageResults")
  field(:stream, 14, type: Livekit.StreamInfo, deprecated: true)
  field(:file, 15, type: Livekit.FileInfo, deprecated: true)
end

defmodule Livekit.StreamInfo do
  @moduledoc false

  use Protobuf, protoc_gen_elixir_version: "0.14.0", syntax: :proto3

  field(:url, 1, type: :string)
  field(:started_at, 2, type: :int64, json_name: "startedAt")
  field(:ended_at, 3, type: :int64, json_name: "endedAt")
  field(:duration, 4, type: :int64)
  field(:status, 5, type: Livekit.StreamInfo.Status, enum: true)
  field(:error, 6, type: :string)
end

defmodule Livekit.FileInfo do
  @moduledoc false

  use Protobuf, protoc_gen_elixir_version: "0.14.0", syntax: :proto3

  field(:filename, 1, type: :string)
  field(:started_at, 2, type: :int64, json_name: "startedAt")
  field(:ended_at, 3, type: :int64, json_name: "endedAt")
  field(:duration, 6, type: :int64)
  field(:size, 4, type: :int64)
  field(:location, 5, type: :string)
end

defmodule Livekit.SegmentedFileInfo do
  @moduledoc false

  use Protobuf, protoc_gen_elixir_version: "0.14.0", syntax: :proto3

  field(:playlist, 1, type: :string)
  field(:started_at, 2, type: :int64, json_name: "startedAt")
  field(:ended_at, 3, type: :int64, json_name: "endedAt")
  field(:duration, 4, type: :int64)
  field(:size, 5, type: :int64)
  field(:playlist_location, 6, type: :string, json_name: "playlistLocation")
  field(:segment_count, 7, type: :int64, json_name: "segmentCount")
end

defmodule Livekit.ImagesInfo do
  @moduledoc false

  use Protobuf, protoc_gen_elixir_version: "0.14.0", syntax: :proto3

  field(:started_at, 1, type: :int64, json_name: "startedAt")
  field(:ended_at, 2, type: :int64, json_name: "endedAt")
  field(:image_count, 3, type: :int64, json_name: "imageCount")
end

defmodule Livekit.DirectFileOutput do
  @moduledoc false

  use Protobuf, protoc_gen_elixir_version: "0.14.0", syntax: :proto3

  oneof(:output, 0)

  field(:filepath, 1, type: :string)
  field(:disable_manifest, 5, type: :bool, json_name: "disableManifest")
  field(:s3, 2, type: Livekit.S3Upload, oneof: 0)
  field(:gcp, 3, type: Livekit.GCPUpload, oneof: 0)
  field(:azure, 4, type: Livekit.AzureBlobUpload, oneof: 0)
  field(:alioss, 6, type: Livekit.AliOSSUpload, oneof: 0)
end

defmodule Livekit.EncodedFileOutput do
  @moduledoc false

  use Protobuf, protoc_gen_elixir_version: "0.14.0", syntax: :proto3

  oneof(:output, 0)

  field(:file_type, 1, type: Livekit.EncodedFileType, json_name: "fileType", enum: true)
  field(:filepath, 2, type: :string)
  field(:disable_manifest, 6, type: :bool, json_name: "disableManifest")
  field(:s3, 3, type: Livekit.S3Upload, oneof: 0)
  field(:gcp, 4, type: Livekit.GCPUpload, oneof: 0)
  field(:azure, 5, type: Livekit.AzureBlobUpload, oneof: 0)
  field(:alioss, 7, type: Livekit.AliOSSUpload, oneof: 0)
end

defmodule Livekit.SegmentedFileOutput do
  @moduledoc false

  use Protobuf, protoc_gen_elixir_version: "0.14.0", syntax: :proto3

  oneof(:output, 0)

  field(:protocol, 1, type: Livekit.SegmentedFileProtocol, enum: true)
  field(:filename_prefix, 2, type: :string, json_name: "filenamePrefix")
  field(:playlist_name, 3, type: :string, json_name: "playlistName")
  field(:segment_duration, 4, type: :uint32, json_name: "segmentDuration")
  field(:filename_suffix, 11, type: :string, json_name: "filenameSuffix")
  field(:disable_manifest, 8, type: :bool, json_name: "disableManifest")
  field(:s3, 5, type: Livekit.S3Upload, oneof: 0)
  field(:gcp, 6, type: Livekit.GCPUpload, oneof: 0)
  field(:azure, 7, type: Livekit.AzureBlobUpload, oneof: 0)
  field(:alioss, 9, type: Livekit.AliOSSUpload, oneof: 0)
end

defmodule Livekit.StreamOutput do
  @moduledoc false

  use Protobuf, protoc_gen_elixir_version: "0.14.0", syntax: :proto3

  field(:protocol, 1, type: Livekit.StreamProtocol, enum: true)
  field(:urls, 2, repeated: true, type: :string)
end

defmodule Livekit.ImageOutput do
  @moduledoc false

  use Protobuf, protoc_gen_elixir_version: "0.14.0", syntax: :proto3

  oneof(:output, 0)

  field(:codec, 1, type: Livekit.ImageCodec, enum: true)
  field(:width, 2, type: :uint32)
  field(:height, 3, type: :uint32)
  field(:filename_prefix, 4, type: :string, json_name: "filenamePrefix")
  field(:filename_suffix, 5, type: :string, json_name: "filenameSuffix")
  field(:image_interval, 6, type: :uint32, json_name: "imageInterval")
  field(:disable_manifest, 7, type: :bool, json_name: "disableManifest")
  field(:s3, 8, type: Livekit.S3Upload, oneof: 0)
  field(:gcp, 9, type: Livekit.GCPUpload, oneof: 0)
  field(:azure, 10, type: Livekit.AzureBlobUpload, oneof: 0)
  field(:alioss, 11, type: Livekit.AliOSSUpload, oneof: 0)
end

defmodule Livekit.S3Upload.MetadataEntry do
  @moduledoc false

  use Protobuf, map: true, protoc_gen_elixir_version: "0.14.0", syntax: :proto3

  field(:key, 1, type: :string)
  field(:value, 2, type: :string)
end

defmodule Livekit.S3Upload do
  @moduledoc false

  use Protobuf, protoc_gen_elixir_version: "0.14.0", syntax: :proto3

  field(:access_key, 1, type: :string, json_name: "accessKey")
  field(:secret, 2, type: :string)
  field(:session_token, 9, type: :string, json_name: "sessionToken")
  field(:region, 3, type: :string)
  field(:endpoint, 4, type: :string)
  field(:bucket, 5, type: :string)
  field(:force_path_style, 6, type: :bool, json_name: "forcePathStyle")
  field(:metadata, 7, repeated: true, type: Livekit.S3Upload.MetadataEntry, map: true)
  field(:tagging, 8, type: :string)
end

defmodule Livekit.GCPUpload do
  @moduledoc false

  use Protobuf, protoc_gen_elixir_version: "0.14.0", syntax: :proto3

  field(:credentials, 1, type: :bytes)
  field(:bucket, 2, type: :string)
end

defmodule Livekit.AzureBlobUpload do
  @moduledoc false

  use Protobuf, protoc_gen_elixir_version: "0.14.0", syntax: :proto3

  field(:account_name, 1, type: :string, json_name: "accountName")
  field(:account_key, 2, type: :string, json_name: "accountKey")
  field(:container_name, 3, type: :string, json_name: "containerName")
end

defmodule Livekit.AliOSSUpload do
  @moduledoc false

  use Protobuf, protoc_gen_elixir_version: "0.14.0", syntax: :proto3

  field(:access_key, 1, type: :string, json_name: "accessKey")
  field(:secret, 2, type: :string)
  field(:region, 3, type: :string)
  field(:endpoint, 4, type: :string)
  field(:bucket, 5, type: :string)
end

defmodule Livekit.EncodingOptions do
  @moduledoc false

  use Protobuf, protoc_gen_elixir_version: "0.14.0", syntax: :proto3

  field(:width, 1, type: :int32)
  field(:height, 2, type: :int32)
  field(:depth, 3, type: :int32)
  field(:framerate, 4, type: :int32)
  field(:audio_codec, 5, type: Livekit.AudioCodec, json_name: "audioCodec", enum: true)
  field(:audio_bitrate, 6, type: :int32, json_name: "audioBitrate")
  field(:audio_quality, 11, type: :int32, json_name: "audioQuality")
  field(:audio_frequency, 7, type: :int32, json_name: "audioFrequency")
  field(:video_codec, 8, type: Livekit.VideoCodec, json_name: "videoCodec", enum: true)
  field(:video_bitrate, 9, type: :int32, json_name: "videoBitrate")
  field(:video_quality, 12, type: :int32, json_name: "videoQuality")
  field(:video_profile, 10, type: Livekit.H264Profile, json_name: "videoProfile", enum: true)
end

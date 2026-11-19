defmodule Livekitex.Proto.Livekit.MetricLabel do
  @moduledoc """
  index from [0: MAX_LABEL_PREDEFINED_MAX_VALUE) are for predefined labels (`MetricLabel`)
  Protocol used to record metrics for a specific session.

  Clients send their timestamp in their own monotonically increasing time (e.g `performance.now` on JS).
  These timestamps are then augmented by the SFU to its time base.

  A metric can be linked to a specific track by setting `track_sid`.
  """

  use Protobuf,
    enum: true,
    full_name: "livekit.MetricLabel",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :AGENTS_LLM_TTFT, 0
  field :AGENTS_STT_TTFT, 1
  field :AGENTS_TTS_TTFB, 2
  field :CLIENT_VIDEO_SUBSCRIBER_FREEZE_COUNT, 3
  field :CLIENT_VIDEO_SUBSCRIBER_TOTAL_FREEZE_DURATION, 4
  field :CLIENT_VIDEO_SUBSCRIBER_PAUSE_COUNT, 5
  field :CLIENT_VIDEO_SUBSCRIBER_TOTAL_PAUSES_DURATION, 6
  field :CLIENT_AUDIO_SUBSCRIBER_CONCEALED_SAMPLES, 7
  field :CLIENT_AUDIO_SUBSCRIBER_SILENT_CONCEALED_SAMPLES, 8
  field :CLIENT_AUDIO_SUBSCRIBER_CONCEALMENT_EVENTS, 9
  field :CLIENT_AUDIO_SUBSCRIBER_INTERRUPTION_COUNT, 10
  field :CLIENT_AUDIO_SUBSCRIBER_TOTAL_INTERRUPTION_DURATION, 11
  field :CLIENT_SUBSCRIBER_JITTER_BUFFER_DELAY, 12
  field :CLIENT_SUBSCRIBER_JITTER_BUFFER_EMITTED_COUNT, 13
  field :CLIENT_VIDEO_PUBLISHER_QUALITY_LIMITATION_DURATION_BANDWIDTH, 14
  field :CLIENT_VIDEO_PUBLISHER_QUALITY_LIMITATION_DURATION_CPU, 15
  field :CLIENT_VIDEO_PUBLISHER_QUALITY_LIMITATION_DURATION_OTHER, 16
  field :PUBLISHER_RTT, 17
  field :SERVER_MESH_RTT, 18
  field :SUBSCRIBER_RTT, 19
  field :METRIC_LABEL_PREDEFINED_MAX_VALUE, 4096
end

defmodule Livekitex.Proto.Livekit.MetricsBatch do
  use Protobuf,
    full_name: "livekit.MetricsBatch",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :timestamp_ms, 1, type: :int64, json_name: "timestampMs"

  field :normalized_timestamp, 2,
    type: Google.Protobuf.Timestamp,
    json_name: "normalizedTimestamp"

  field :str_data, 3, repeated: true, type: :string, json_name: "strData"

  field :time_series, 4,
    repeated: true,
    type: Livekitex.Proto.Livekit.TimeSeriesMetric,
    json_name: "timeSeries"

  field :events, 5, repeated: true, type: Livekitex.Proto.Livekit.EventMetric
end

defmodule Livekitex.Proto.Livekit.TimeSeriesMetric do
  use Protobuf,
    full_name: "livekit.TimeSeriesMetric",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :label, 1, type: :uint32
  field :participant_identity, 2, type: :uint32, json_name: "participantIdentity"
  field :track_sid, 3, type: :uint32, json_name: "trackSid"
  field :samples, 4, repeated: true, type: Livekitex.Proto.Livekit.MetricSample
  field :rid, 5, type: :uint32
end

defmodule Livekitex.Proto.Livekit.MetricSample do
  use Protobuf,
    full_name: "livekit.MetricSample",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :timestamp_ms, 1, type: :int64, json_name: "timestampMs"

  field :normalized_timestamp, 2,
    type: Google.Protobuf.Timestamp,
    json_name: "normalizedTimestamp"

  field :value, 3, type: :float
end

defmodule Livekitex.Proto.Livekit.EventMetric do
  use Protobuf,
    full_name: "livekit.EventMetric",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :label, 1, type: :uint32
  field :participant_identity, 2, type: :uint32, json_name: "participantIdentity"
  field :track_sid, 3, type: :uint32, json_name: "trackSid"
  field :start_timestamp_ms, 4, type: :int64, json_name: "startTimestampMs"
  field :end_timestamp_ms, 5, proto3_optional: true, type: :int64, json_name: "endTimestampMs"

  field :normalized_start_timestamp, 6,
    type: Google.Protobuf.Timestamp,
    json_name: "normalizedStartTimestamp"

  field :normalized_end_timestamp, 7,
    proto3_optional: true,
    type: Google.Protobuf.Timestamp,
    json_name: "normalizedEndTimestamp"

  field :metadata, 8, type: :string
  field :rid, 9, type: :uint32
end

defmodule Livekitex.Proto.Livekit.MetricsRecordingHeader.RoomTagsEntry do
  use Protobuf,
    full_name: "livekit.MetricsRecordingHeader.RoomTagsEntry",
    map: true,
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :key, 1, type: :string
  field :value, 2, type: :string
end

defmodule Livekitex.Proto.Livekit.MetricsRecordingHeader do
  use Protobuf,
    full_name: "livekit.MetricsRecordingHeader",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :room_id, 1, type: :string, json_name: "roomId", deprecated: false
  field :duration, 3, type: :uint64
  field :start_time, 4, type: Google.Protobuf.Timestamp, json_name: "startTime"

  field :room_tags, 5,
    repeated: true,
    type: Livekitex.Proto.Livekit.MetricsRecordingHeader.RoomTagsEntry,
    json_name: "roomTags",
    map: true

  field :room_name, 6, type: :string, json_name: "roomName"
  field :room_start_time, 7, type: Google.Protobuf.Timestamp, json_name: "roomStartTime"
  field :job_id, 8, type: :string, json_name: "jobId"
  field :simulated, 9, type: :bool
  field :redaction_enabled, 10, type: :bool, json_name: "redactionEnabled"
  field :session_summary, 11, type: :string, json_name: "sessionSummary"
end

defmodule Livekitex.Proto.Livekit.JobType do
  use Protobuf,
    enum: true,
    full_name: "livekit.JobType",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :JT_ROOM, 0
  field :JT_PUBLISHER, 1
  field :JT_PARTICIPANT, 2
end

defmodule Livekitex.Proto.Livekit.WorkerStatus do
  use Protobuf,
    enum: true,
    full_name: "livekit.WorkerStatus",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :WS_AVAILABLE, 0
  field :WS_FULL, 1
end

defmodule Livekitex.Proto.Livekit.JobStatus do
  use Protobuf,
    enum: true,
    full_name: "livekit.JobStatus",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :JS_PENDING, 0
  field :JS_RUNNING, 1
  field :JS_SUCCESS, 2
  field :JS_FAILED, 3
  field :JS_CANCELLED, 4
end

defmodule Livekitex.Proto.Livekit.JobStateReason do
  use Protobuf,
    enum: true,
    full_name: "livekit.JobStateReason",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :JSR_UNSPECIFIED, 0
  field :JSR_NO_CAPACITY, 1
  field :JSR_ROOM_CLOSED, 2
  field :JSR_DISPATCH_DELETED, 3
  field :JSR_RETRYING, 4
end

defmodule Livekitex.Proto.Livekit.AgentHttp.AgentEndpointKind do
  use Protobuf,
    enum: true,
    full_name: "livekit.AgentHttp.AgentEndpointKind",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :AEK_HTTP, 0
  field :AEK_TEXT, 1
end

defmodule Livekitex.Proto.Livekit.AgentHttp.HttpStreamResetCode do
  @moduledoc """
  why a stream was reset before any HTTP bytes flowed. This travels as the
  QUIC RESET_STREAM / STOP_SENDING error code, so it is a number with no room
  for detail: the reason string is logged by the side that reset and joined
  to this by request_id. An outcome after bytes have flowed travels in
  trailers instead, where it cannot race them.
  """

  use Protobuf,
    enum: true,
    full_name: "livekit.AgentHttp.HttpStreamResetCode",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :HSR_ABORT, 0
  field :HSR_REFUSED, 1
  field :HSR_INTERNAL, 2
  field :HSR_TIMEOUT, 3
  field :HSR_PROTOCOL, 4
end

defmodule Livekitex.Proto.Livekit.Job.AttributesEntry do
  use Protobuf,
    full_name: "livekit.Job.AttributesEntry",
    map: true,
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :key, 1, type: :string
  field :value, 2, type: :string
end

defmodule Livekitex.Proto.Livekit.Job do
  use Protobuf, full_name: "livekit.Job", protoc_gen_elixir_version: "0.17.1", syntax: :proto3

  field :id, 1, type: :string
  field :dispatch_id, 9, type: :string, json_name: "dispatchId", deprecated: false
  field :type, 2, type: Livekitex.Proto.Livekit.JobType, enum: true
  field :room, 3, type: Livekitex.Proto.Livekit.Room
  field :participant, 4, proto3_optional: true, type: Livekitex.Proto.Livekit.ParticipantInfo
  field :namespace, 5, type: :string, deprecated: true
  field :metadata, 6, type: :string, deprecated: false
  field :agent_name, 7, type: :string, json_name: "agentName"
  field :state, 8, type: Livekitex.Proto.Livekit.JobState
  field :enable_recording, 10, type: :bool, json_name: "enableRecording"
  field :deployment, 11, type: :string

  field :attributes, 12,
    repeated: true,
    type: Livekitex.Proto.Livekit.Job.AttributesEntry,
    map: true,
    deprecated: false

  field :enable_redaction, 13, type: :bool, json_name: "enableRedaction"
  field :created_at, 14, type: :int64, json_name: "createdAt"
  field :thread_id, 15, type: :string, json_name: "threadId"
end

defmodule Livekitex.Proto.Livekit.JobState do
  use Protobuf,
    full_name: "livekit.JobState",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :status, 1, type: Livekitex.Proto.Livekit.JobStatus, enum: true
  field :error, 2, type: :string
  field :started_at, 3, type: :int64, json_name: "startedAt"
  field :ended_at, 4, type: :int64, json_name: "endedAt"
  field :updated_at, 5, type: :int64, json_name: "updatedAt"
  field :participant_identity, 6, type: :string, json_name: "participantIdentity"
  field :worker_id, 7, type: :string, json_name: "workerId", deprecated: false
  field :agent_id, 8, type: :string, json_name: "agentId", deprecated: false
  field :reason, 9, type: Livekitex.Proto.Livekit.JobStateReason, enum: true
  field :accepted_at, 10, type: :int64, json_name: "acceptedAt"
  field :assigned_at, 11, type: :int64, json_name: "assignedAt"
  field :attempts, 12, type: :uint32
  field :first_started_at, 13, type: :int64, json_name: "firstStartedAt"
  field :agent_failed_attempts_ns, 14, type: :int64, json_name: "agentFailedAttemptsNs"
  field :workers_asked, 15, type: :uint32, json_name: "workersAsked"
end

defmodule Livekitex.Proto.Livekit.WorkerMessage do
  @moduledoc """
  from Worker to Server
  """

  use Protobuf,
    full_name: "livekit.WorkerMessage",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  oneof :message, 0

  field :register, 1, type: Livekitex.Proto.Livekit.RegisterWorkerRequest, oneof: 0
  field :availability, 2, type: Livekitex.Proto.Livekit.AvailabilityResponse, oneof: 0

  field :update_worker, 3,
    type: Livekitex.Proto.Livekit.UpdateWorkerStatus,
    json_name: "updateWorker",
    oneof: 0

  field :update_job, 4,
    type: Livekitex.Proto.Livekit.UpdateJobStatus,
    json_name: "updateJob",
    oneof: 0

  field :ping, 5, type: Livekitex.Proto.Livekit.WorkerPing, oneof: 0

  field :simulate_job, 6,
    type: Livekitex.Proto.Livekit.SimulateJobRequest,
    json_name: "simulateJob",
    oneof: 0

  field :migrate_job, 7,
    type: Livekitex.Proto.Livekit.MigrateJobRequest,
    json_name: "migrateJob",
    oneof: 0

  field :create_job_token, 8,
    type: Livekitex.Proto.Livekit.CreateJobTokenRequest,
    json_name: "createJobToken",
    oneof: 0
end

defmodule Livekitex.Proto.Livekit.ServerMessage do
  @moduledoc """
  from Server to Worker
  """

  use Protobuf,
    full_name: "livekit.ServerMessage",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  oneof :message, 0

  field :register, 1, type: Livekitex.Proto.Livekit.RegisterWorkerResponse, oneof: 0
  field :availability, 2, type: Livekitex.Proto.Livekit.AvailabilityRequest, oneof: 0
  field :assignment, 3, type: Livekitex.Proto.Livekit.JobAssignment, oneof: 0
  field :termination, 5, type: Livekitex.Proto.Livekit.JobTermination, oneof: 0
  field :pong, 4, type: Livekitex.Proto.Livekit.WorkerPong, oneof: 0
  field :go_away, 6, type: Livekitex.Proto.Livekit.AgentHttp.GoAway, json_name: "goAway", oneof: 0

  field :create_job_token, 7,
    type: Livekitex.Proto.Livekit.CreateJobTokenResponse,
    json_name: "createJobToken",
    oneof: 0
end

defmodule Livekitex.Proto.Livekit.SimulateJobRequest do
  use Protobuf,
    full_name: "livekit.SimulateJobRequest",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :type, 1, type: Livekitex.Proto.Livekit.JobType, enum: true
  field :room, 2, type: Livekitex.Proto.Livekit.Room
  field :participant, 3, type: Livekitex.Proto.Livekit.ParticipantInfo
end

defmodule Livekitex.Proto.Livekit.WorkerPing do
  use Protobuf,
    full_name: "livekit.WorkerPing",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :timestamp, 1, type: :int64
end

defmodule Livekitex.Proto.Livekit.WorkerPong do
  use Protobuf,
    full_name: "livekit.WorkerPong",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :last_timestamp, 1, type: :int64, json_name: "lastTimestamp"
  field :timestamp, 2, type: :int64
end

defmodule Livekitex.Proto.Livekit.RegisterWorkerRequest do
  use Protobuf,
    full_name: "livekit.RegisterWorkerRequest",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :type, 1, type: Livekitex.Proto.Livekit.JobType, enum: true
  field :agent_name, 8, type: :string, json_name: "agentName"
  field :version, 3, type: :string
  field :ping_interval, 5, type: :uint32, json_name: "pingInterval"
  field :namespace, 6, proto3_optional: true, type: :string

  field :allowed_permissions, 7,
    type: Livekitex.Proto.Livekit.ParticipantPermission,
    json_name: "allowedPermissions"

  field :deployment, 9, type: :string
  field :endpoints, 10, repeated: true, type: Livekitex.Proto.Livekit.AgentHttp.AgentEndpoint
  field :instance_id, 11, type: :string, json_name: "instanceId", deprecated: false
  field :endpoint_protocol, 12, type: :uint32, json_name: "endpointProtocol"
end

defmodule Livekitex.Proto.Livekit.RegisterWorkerResponse do
  use Protobuf,
    full_name: "livekit.RegisterWorkerResponse",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :worker_id, 1, type: :string, json_name: "workerId", deprecated: false
  field :server_info, 3, type: Livekitex.Proto.Livekit.ServerInfo, json_name: "serverInfo"

  field :endpoint_settings, 4,
    type: Livekitex.Proto.Livekit.AgentHttp.AgentEndpointSettings,
    json_name: "endpointSettings"
end

defmodule Livekitex.Proto.Livekit.MigrateJobRequest do
  use Protobuf,
    full_name: "livekit.MigrateJobRequest",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :job_ids, 2, repeated: true, type: :string, json_name: "jobIds"
  field :jobs, 3, repeated: true, type: Livekitex.Proto.Livekit.Job
end

defmodule Livekitex.Proto.Livekit.AvailabilityRequest do
  use Protobuf,
    full_name: "livekit.AvailabilityRequest",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :job, 1, type: Livekitex.Proto.Livekit.Job
  field :resuming, 2, type: :bool
end

defmodule Livekitex.Proto.Livekit.AvailabilityResponse.ParticipantAttributesEntry do
  use Protobuf,
    full_name: "livekit.AvailabilityResponse.ParticipantAttributesEntry",
    map: true,
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :key, 1, type: :string
  field :value, 2, type: :string
end

defmodule Livekitex.Proto.Livekit.AvailabilityResponse do
  use Protobuf,
    full_name: "livekit.AvailabilityResponse",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :job_id, 1, type: :string, json_name: "jobId", deprecated: false
  field :available, 2, type: :bool
  field :supports_resume, 3, type: :bool, json_name: "supportsResume"
  field :terminate, 8, type: :bool
  field :participant_name, 4, type: :string, json_name: "participantName"
  field :participant_identity, 5, type: :string, json_name: "participantIdentity"
  field :participant_metadata, 6, type: :string, json_name: "participantMetadata"

  field :participant_attributes, 7,
    repeated: true,
    type: Livekitex.Proto.Livekit.AvailabilityResponse.ParticipantAttributesEntry,
    json_name: "participantAttributes",
    map: true
end

defmodule Livekitex.Proto.Livekit.UpdateJobStatus do
  use Protobuf,
    full_name: "livekit.UpdateJobStatus",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :job_id, 1, type: :string, json_name: "jobId", deprecated: false
  field :status, 2, type: Livekitex.Proto.Livekit.JobStatus, enum: true
  field :error, 3, type: :string
  field :join_timing, 4, type: Livekitex.Proto.Livekit.JobJoinTiming, json_name: "joinTiming"
end

defmodule Livekitex.Proto.Livekit.JobJoinTiming do
  @moduledoc """
  Instants of one agent join on the worker host's monotonic clock, in microseconds. The
  clock origin is arbitrary, so only differences between these values carry meaning on
  their own. The worker and its job processes share this clock.
  """

  use Protobuf,
    full_name: "livekit.JobJoinTiming",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :offer_received_us, 1, type: :int64, json_name: "offerReceivedUs"
  field :accepted_us, 2, type: :int64, json_name: "acceptedUs"
  field :assignment_received_us, 3, type: :int64, json_name: "assignmentReceivedUs"
  field :launched_us, 4, type: :int64, json_name: "launchedUs"
  field :launch_warm, 5, type: :bool, json_name: "launchWarm"
  field :entrypoint_started_us, 6, type: :int64, json_name: "entrypointStartedUs"
  field :connect_called_us, 7, type: :int64, json_name: "connectCalledUs"
  field :connected_us, 8, type: :int64, json_name: "connectedUs"
end

defmodule Livekitex.Proto.Livekit.UpdateWorkerStatus do
  use Protobuf,
    full_name: "livekit.UpdateWorkerStatus",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :status, 1, proto3_optional: true, type: Livekitex.Proto.Livekit.WorkerStatus, enum: true
  field :load, 3, type: :float
  field :job_count, 4, type: :uint32, json_name: "jobCount"
  field :draining, 5, type: :bool
  field :seq, 6, type: :uint64
end

defmodule Livekitex.Proto.Livekit.JobAssignment do
  use Protobuf,
    full_name: "livekit.JobAssignment",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :job, 1, type: Livekitex.Proto.Livekit.Job
  field :url, 2, proto3_optional: true, type: :string
  field :token, 3, type: :string, deprecated: false
end

defmodule Livekitex.Proto.Livekit.JobTermination do
  use Protobuf,
    full_name: "livekit.JobTermination",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :job_id, 1, type: :string, json_name: "jobId", deprecated: false
end

defmodule Livekitex.Proto.Livekit.CreateJobTokenRequest do
  use Protobuf,
    full_name: "livekit.CreateJobTokenRequest",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :request_id, 1, type: :string, json_name: "requestId", deprecated: false
  field :job_id, 2, type: :string, json_name: "jobId", deprecated: false
  field :claims, 3, type: :string
end

defmodule Livekitex.Proto.Livekit.CreateJobTokenResponse do
  use Protobuf,
    full_name: "livekit.CreateJobTokenResponse",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :request_id, 1, type: :string, json_name: "requestId", deprecated: false
  field :token, 2, type: :string, deprecated: false
  field :expires_at, 3, type: :int64, json_name: "expiresAt"
  field :error, 4, type: :string
end

defmodule Livekitex.Proto.Livekit.AgentHttp.AgentEndpoint do
  use Protobuf,
    full_name: "livekit.AgentHttp.AgentEndpoint",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :path, 1, type: :string
  field :methods, 2, repeated: true, type: :string
  field :kind, 3, type: Livekitex.Proto.Livekit.AgentHttp.AgentEndpointKind, enum: true
  field :public, 4, type: :bool
end

defmodule Livekitex.Proto.Livekit.AgentHttp.AgentEndpointSettings do
  @moduledoc """
  registration-level settings negotiated on the control connection, returned
  in RegisterWorkerResponse when the worker declares endpoints and the server
  supports the data plane.
  """

  use Protobuf,
    full_name: "livekit.AgentHttp.AgentEndpointSettings",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :protocol, 1, type: :uint32
end

defmodule Livekitex.Proto.Livekit.AgentHttp.StreamPreamble do
  @moduledoc """
  the first thing on every exchange stream, node -> worker. It carries only
  what the worker cannot derive from the HTTP bytes that follow and what it
  must not infer from client-supplied headers - identity above all.
  """

  use Protobuf,
    full_name: "livekit.AgentHttp.StreamPreamble",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :kind, 1, type: Livekitex.Proto.Livekit.AgentHttp.AgentEndpointKind, enum: true
  field :request_id, 2, type: :string, json_name: "requestId", deprecated: false
  field :authorized, 3, type: :bool
  field :route, 4, type: :string
  field :timeout_ms, 5, type: :uint32, json_name: "timeoutMs"
  field :client_addr, 6, type: :string, json_name: "clientAddr", deprecated: false
  field :scheme, 7, type: :string
end

defmodule Livekitex.Proto.Livekit.AgentHttp.GoAway do
  @moduledoc """
  the server is draining: the worker should re-register elsewhere; in-flight
  HTTP exchanges run to completion
  """

  use Protobuf,
    full_name: "livekit.AgentHttp.GoAway",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :reason, 1, type: :string
end

defmodule Livekitex.Proto.Livekit.AgentHttp do
  @moduledoc """
  ----- agent HTTP endpoints data plane -----

  AgentHttp namespaces the data plane: workers expose HTTP endpoints served at
  /agents/{agent_name}/{deployment}/{path} without binding any local listener.
  The worker opens ONE WebTransport (QUIC) session to /agent that carries both
  its control stream (the same WorkerMessage/ServerMessage exchange as the
  WebSocket control connection, length-delimited) and every HTTP exchange: the
  node opens one bidirectional QUIC stream per request. QUIC provides the
  multiplexing and per-stream flow control, so there is no credit accounting
  and no attach handshake.

  Each exchange stream is:

    [len:u32be][StreamPreamble]   the only LiveKit framing
    [ ... opaque bytes ... ]      one HTTP/1.1 exchange, to FIN or RESET_STREAM

  After the preamble the stream is byte-transparent: the node writes a
  canonical HTTP/1.1 request and the worker replies with an HTTP/1.1 response,
  each parsed by whatever HTTP implementation the side already has. A WebSocket
  upgrade is therefore an ordinary request whose response is a 101, after which
  the stream is a byte pipe. The protocol evolves by version negotiation at
  registration, so the preamble carries no version of its own.

  Bodies use ordinary HTTP/1.1 framing, Content-Length or chunked, and are
  unbounded: a body may be many gigabytes and must be streamed. Request and
  response size limits are policy for the layer above.

  How one direction ends:

    success             end of message per the body's own framing, then FIN.
    failed mid-body     chunked trailer fields x-lk-completion and x-lk-error,
                        in band, so the outcome cannot race the bytes it
                        describes.
    failed before any   RESET_STREAM carrying an HttpStreamResetCode, sound
    bytes               only here, where nothing is in flight.

  FIN before the body's own framing says it is complete is truncation, and a
  receiver must surface it as such.

  The x-lk- header prefix is reserved for this signalling in both directions.
  A node strips it from client-supplied request headers, so a client cannot
  forge one, and strips it from responses, so it never reaches the end client.
  """

  use Protobuf,
    full_name: "livekit.AgentHttp",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3
end

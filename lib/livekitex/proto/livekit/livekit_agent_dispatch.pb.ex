defmodule Livekitex.Proto.Livekit.JobRestartPolicy do
  use Protobuf,
    enum: true,
    full_name: "livekit.JobRestartPolicy",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :JRP_ON_FAILURE, 0
  field :JRP_NEVER, 1
end

defmodule Livekitex.Proto.Livekit.AgentDispatchTrigger do
  @moduledoc """
  what created the dispatch
  """

  use Protobuf,
    enum: true,
    full_name: "livekit.AgentDispatchTrigger",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :ADT_UNSPECIFIED, 0
  field :ADT_JOIN, 1
  field :ADT_ROOM_API, 2
  field :ADT_DISPATCH_API, 3
end

defmodule Livekitex.Proto.Livekit.CreateAgentDispatchRequest.AttributesEntry do
  use Protobuf,
    full_name: "livekit.CreateAgentDispatchRequest.AttributesEntry",
    map: true,
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :key, 1, type: :string
  field :value, 2, type: :string
end

defmodule Livekitex.Proto.Livekit.CreateAgentDispatchRequest do
  use Protobuf,
    full_name: "livekit.CreateAgentDispatchRequest",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :agent_name, 1, type: :string, json_name: "agentName"
  field :room, 2, type: :string
  field :metadata, 3, type: :string, deprecated: false

  field :restart_policy, 4,
    type: Livekitex.Proto.Livekit.JobRestartPolicy,
    json_name: "restartPolicy",
    enum: true

  field :deployment, 5, type: :string

  field :attributes, 6,
    repeated: true,
    type: Livekitex.Proto.Livekit.CreateAgentDispatchRequest.AttributesEntry,
    map: true,
    deprecated: false

  field :thread_id, 7, type: :string, json_name: "threadId"
end

defmodule Livekitex.Proto.Livekit.RoomAgentDispatch.AttributesEntry do
  use Protobuf,
    full_name: "livekit.RoomAgentDispatch.AttributesEntry",
    map: true,
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :key, 1, type: :string
  field :value, 2, type: :string
end

defmodule Livekitex.Proto.Livekit.RoomAgentDispatch do
  use Protobuf,
    full_name: "livekit.RoomAgentDispatch",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :agent_name, 1, type: :string, json_name: "agentName"
  field :metadata, 2, type: :string, deprecated: false

  field :restart_policy, 3,
    type: Livekitex.Proto.Livekit.JobRestartPolicy,
    json_name: "restartPolicy",
    enum: true

  field :deployment, 4, type: :string

  field :attributes, 5,
    repeated: true,
    type: Livekitex.Proto.Livekit.RoomAgentDispatch.AttributesEntry,
    map: true,
    deprecated: false

  field :thread_id, 6, type: :string, json_name: "threadId"
end

defmodule Livekitex.Proto.Livekit.DeleteAgentDispatchRequest do
  use Protobuf,
    full_name: "livekit.DeleteAgentDispatchRequest",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :dispatch_id, 1, type: :string, json_name: "dispatchId", deprecated: false
  field :room, 2, type: :string
end

defmodule Livekitex.Proto.Livekit.ListAgentDispatchRequest do
  use Protobuf,
    full_name: "livekit.ListAgentDispatchRequest",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :dispatch_id, 1, type: :string, json_name: "dispatchId", deprecated: false
  field :room, 2, type: :string
end

defmodule Livekitex.Proto.Livekit.ListAgentDispatchResponse do
  use Protobuf,
    full_name: "livekit.ListAgentDispatchResponse",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :agent_dispatches, 1,
    repeated: true,
    type: Livekitex.Proto.Livekit.AgentDispatch,
    json_name: "agentDispatches"
end

defmodule Livekitex.Proto.Livekit.AgentDispatch.AttributesEntry do
  use Protobuf,
    full_name: "livekit.AgentDispatch.AttributesEntry",
    map: true,
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :key, 1, type: :string
  field :value, 2, type: :string
end

defmodule Livekitex.Proto.Livekit.AgentDispatch do
  use Protobuf,
    full_name: "livekit.AgentDispatch",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :id, 1, type: :string
  field :agent_name, 2, type: :string, json_name: "agentName"
  field :room, 3, type: :string
  field :metadata, 4, type: :string, deprecated: false
  field :state, 5, type: Livekitex.Proto.Livekit.AgentDispatchState

  field :restart_policy, 6,
    type: Livekitex.Proto.Livekit.JobRestartPolicy,
    json_name: "restartPolicy",
    enum: true

  field :deployment, 7, type: :string

  field :attributes, 8,
    repeated: true,
    type: Livekitex.Proto.Livekit.AgentDispatch.AttributesEntry,
    map: true,
    deprecated: false

  field :thread_id, 9, type: :string, json_name: "threadId"
end

defmodule Livekitex.Proto.Livekit.AgentDispatchState do
  use Protobuf,
    full_name: "livekit.AgentDispatchState",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :jobs, 1, repeated: true, type: Livekitex.Proto.Livekit.Job
  field :created_at, 2, type: :int64, json_name: "createdAt"
  field :deleted_at, 3, type: :int64, json_name: "deletedAt"
  field :trigger, 4, type: Livekitex.Proto.Livekit.AgentDispatchTrigger, enum: true
end

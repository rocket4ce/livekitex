defmodule Livekitex.Proto.Livekit.CreateRoomRequest.TagsEntry do
  use Protobuf,
    full_name: "livekit.CreateRoomRequest.TagsEntry",
    map: true,
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :key, 1, type: :string
  field :value, 2, type: :string
end

defmodule Livekitex.Proto.Livekit.CreateRoomRequest do
  use Protobuf,
    full_name: "livekit.CreateRoomRequest",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :name, 1, type: :string
  field :room_preset, 12, type: :string, json_name: "roomPreset"
  field :empty_timeout, 2, type: :uint32, json_name: "emptyTimeout"
  field :departure_timeout, 10, type: :uint32, json_name: "departureTimeout"
  field :max_participants, 3, type: :uint32, json_name: "maxParticipants"
  field :node_id, 4, type: :string, json_name: "nodeId", deprecated: false
  field :metadata, 5, type: :string, deprecated: false

  field :tags, 15,
    repeated: true,
    type: Livekitex.Proto.Livekit.CreateRoomRequest.TagsEntry,
    map: true

  field :egress, 6, type: Livekitex.Proto.Livekit.RoomEgress
  field :min_playout_delay, 7, type: :uint32, json_name: "minPlayoutDelay"
  field :max_playout_delay, 8, type: :uint32, json_name: "maxPlayoutDelay"
  field :sync_streams, 9, type: :bool, json_name: "syncStreams"
  field :replay_enabled, 13, type: :bool, json_name: "replayEnabled"
  field :agents, 14, repeated: true, type: Livekitex.Proto.Livekit.RoomAgentDispatch
end

defmodule Livekitex.Proto.Livekit.RoomEgress do
  use Protobuf,
    full_name: "livekit.RoomEgress",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :room, 1, type: Livekitex.Proto.Livekit.RoomCompositeEgressRequest
  field :participant, 3, type: Livekitex.Proto.Livekit.AutoParticipantEgress
  field :tracks, 2, type: Livekitex.Proto.Livekit.AutoTrackEgress
end

defmodule Livekitex.Proto.Livekit.RoomAgent do
  use Protobuf,
    full_name: "livekit.RoomAgent",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :dispatches, 1, repeated: true, type: Livekitex.Proto.Livekit.RoomAgentDispatch
end

defmodule Livekitex.Proto.Livekit.ListRoomsRequest do
  use Protobuf,
    full_name: "livekit.ListRoomsRequest",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :names, 1, repeated: true, type: :string
end

defmodule Livekitex.Proto.Livekit.ListRoomsResponse do
  use Protobuf,
    full_name: "livekit.ListRoomsResponse",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :rooms, 1, repeated: true, type: Livekitex.Proto.Livekit.Room
end

defmodule Livekitex.Proto.Livekit.DeleteRoomRequest do
  use Protobuf,
    full_name: "livekit.DeleteRoomRequest",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :room, 1, type: :string
end

defmodule Livekitex.Proto.Livekit.DeleteRoomResponse do
  use Protobuf,
    full_name: "livekit.DeleteRoomResponse",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3
end

defmodule Livekitex.Proto.Livekit.ListParticipantsRequest do
  use Protobuf,
    full_name: "livekit.ListParticipantsRequest",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :room, 1, type: :string
end

defmodule Livekitex.Proto.Livekit.ListParticipantsResponse do
  use Protobuf,
    full_name: "livekit.ListParticipantsResponse",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :participants, 1, repeated: true, type: Livekitex.Proto.Livekit.ParticipantInfo
end

defmodule Livekitex.Proto.Livekit.RoomParticipantIdentity do
  use Protobuf,
    full_name: "livekit.RoomParticipantIdentity",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :room, 1, type: :string
  field :identity, 2, type: :string
  field :revoke_token_ts, 3, type: :int64, json_name: "revokeTokenTs"
end

defmodule Livekitex.Proto.Livekit.RemoveParticipantResponse do
  use Protobuf,
    full_name: "livekit.RemoveParticipantResponse",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3
end

defmodule Livekitex.Proto.Livekit.MuteRoomTrackRequest do
  use Protobuf,
    full_name: "livekit.MuteRoomTrackRequest",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :room, 1, type: :string
  field :identity, 2, type: :string
  field :track_sid, 3, type: :string, json_name: "trackSid"
  field :muted, 4, type: :bool
end

defmodule Livekitex.Proto.Livekit.MuteRoomTrackResponse do
  use Protobuf,
    full_name: "livekit.MuteRoomTrackResponse",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :track, 1, type: Livekitex.Proto.Livekit.TrackInfo
end

defmodule Livekitex.Proto.Livekit.UpdateParticipantRequest.AttributesEntry do
  use Protobuf,
    full_name: "livekit.UpdateParticipantRequest.AttributesEntry",
    map: true,
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :key, 1, type: :string
  field :value, 2, type: :string
end

defmodule Livekitex.Proto.Livekit.UpdateParticipantRequest do
  use Protobuf,
    full_name: "livekit.UpdateParticipantRequest",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :room, 1, type: :string
  field :identity, 2, type: :string
  field :metadata, 3, type: :string, deprecated: false
  field :permission, 4, type: Livekitex.Proto.Livekit.ParticipantPermission
  field :name, 5, type: :string, deprecated: false

  field :attributes, 6,
    repeated: true,
    type: Livekitex.Proto.Livekit.UpdateParticipantRequest.AttributesEntry,
    map: true,
    deprecated: false
end

defmodule Livekitex.Proto.Livekit.UpdateSubscriptionsRequest do
  use Protobuf,
    full_name: "livekit.UpdateSubscriptionsRequest",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :room, 1, type: :string
  field :identity, 2, type: :string
  field :track_sids, 3, repeated: true, type: :string, json_name: "trackSids"
  field :subscribe, 4, type: :bool

  field :participant_tracks, 5,
    repeated: true,
    type: Livekitex.Proto.Livekit.ParticipantTracks,
    json_name: "participantTracks"
end

defmodule Livekitex.Proto.Livekit.UpdateSubscriptionsResponse do
  @moduledoc """
  empty for now
  """

  use Protobuf,
    full_name: "livekit.UpdateSubscriptionsResponse",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3
end

defmodule Livekitex.Proto.Livekit.SendDataRequest do
  use Protobuf,
    full_name: "livekit.SendDataRequest",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :room, 1, type: :string
  field :data, 2, type: :bytes
  field :kind, 3, type: Livekitex.Proto.Livekit.DataPacket.Kind, enum: true

  field :destination_sids, 4,
    repeated: true,
    type: :string,
    json_name: "destinationSids",
    deprecated: true

  field :destination_identities, 6,
    repeated: true,
    type: :string,
    json_name: "destinationIdentities"

  field :topic, 5, proto3_optional: true, type: :string
  field :nonce, 7, type: :bytes
end

defmodule Livekitex.Proto.Livekit.SendDataResponse do
  use Protobuf,
    full_name: "livekit.SendDataResponse",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3
end

defmodule Livekitex.Proto.Livekit.UpdateRoomMetadataRequest do
  use Protobuf,
    full_name: "livekit.UpdateRoomMetadataRequest",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :room, 1, type: :string
  field :metadata, 2, type: :string, deprecated: false
end

defmodule Livekitex.Proto.Livekit.RoomConfiguration.TagsEntry do
  use Protobuf,
    full_name: "livekit.RoomConfiguration.TagsEntry",
    map: true,
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :key, 1, type: :string
  field :value, 2, type: :string
end

defmodule Livekitex.Proto.Livekit.RoomConfiguration do
  use Protobuf,
    full_name: "livekit.RoomConfiguration",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :name, 1, type: :string
  field :empty_timeout, 2, type: :uint32, json_name: "emptyTimeout"
  field :departure_timeout, 3, type: :uint32, json_name: "departureTimeout"
  field :max_participants, 4, type: :uint32, json_name: "maxParticipants"
  field :metadata, 11, type: :string, deprecated: false
  field :egress, 5, type: Livekitex.Proto.Livekit.RoomEgress
  field :min_playout_delay, 7, type: :uint32, json_name: "minPlayoutDelay"
  field :max_playout_delay, 8, type: :uint32, json_name: "maxPlayoutDelay"
  field :sync_streams, 9, type: :bool, json_name: "syncStreams"
  field :agents, 10, repeated: true, type: Livekitex.Proto.Livekit.RoomAgentDispatch

  field :tags, 12,
    repeated: true,
    type: Livekitex.Proto.Livekit.RoomConfiguration.TagsEntry,
    map: true
end

defmodule Livekitex.Proto.Livekit.ForwardParticipantRequest do
  use Protobuf,
    full_name: "livekit.ForwardParticipantRequest",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :room, 1, type: :string
  field :identity, 2, type: :string
  field :destination_room, 3, type: :string, json_name: "destinationRoom"
end

defmodule Livekitex.Proto.Livekit.ForwardParticipantResponse do
  use Protobuf,
    full_name: "livekit.ForwardParticipantResponse",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3
end

defmodule Livekitex.Proto.Livekit.MoveParticipantRequest do
  use Protobuf,
    full_name: "livekit.MoveParticipantRequest",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :room, 1, type: :string
  field :identity, 2, type: :string
  field :destination_room, 3, type: :string, json_name: "destinationRoom"
end

defmodule Livekitex.Proto.Livekit.MoveParticipantResponse do
  use Protobuf,
    full_name: "livekit.MoveParticipantResponse",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3
end

defmodule Livekitex.Proto.Livekit.PerformRpcRequest do
  use Protobuf,
    full_name: "livekit.PerformRpcRequest",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :room, 1, type: :string
  field :destination_identity, 2, type: :string, json_name: "destinationIdentity"
  field :method, 3, type: :string
  field :payload, 4, type: :string
  field :response_timeout_ms, 5, type: :uint32, json_name: "responseTimeoutMs"
end

defmodule Livekitex.Proto.Livekit.PerformRpcResponse do
  use Protobuf,
    full_name: "livekit.PerformRpcResponse",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :payload, 1, type: :string
end

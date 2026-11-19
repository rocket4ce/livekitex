defmodule Livekitex.Proto.Livekit.WebhookEvent do
  use Protobuf,
    full_name: "livekit.WebhookEvent",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :event, 1, type: :string
  field :room, 2, type: Livekitex.Proto.Livekit.Room
  field :participant, 3, type: Livekitex.Proto.Livekit.ParticipantInfo
  field :egress_info, 9, type: Livekitex.Proto.Livekit.EgressInfo, json_name: "egressInfo"
  field :ingress_info, 10, type: Livekitex.Proto.Livekit.IngressInfo, json_name: "ingressInfo"
  field :track, 8, type: Livekitex.Proto.Livekit.TrackInfo
  field :job, 12, type: Livekitex.Proto.Livekit.Job
  field :id, 6, type: :string
  field :created_at, 7, type: :int64, json_name: "createdAt"
  field :num_dropped, 11, type: :int32, json_name: "numDropped", deprecated: true

  field :room_end_reason, 13,
    type: Livekitex.Proto.Livekit.RoomEndReason,
    json_name: "roomEndReason",
    enum: true
end

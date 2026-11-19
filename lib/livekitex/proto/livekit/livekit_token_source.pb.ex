defmodule Livekitex.Proto.Livekit.TokenSourceRequest.ParticipantAttributesEntry do
  use Protobuf,
    full_name: "livekit.TokenSourceRequest.ParticipantAttributesEntry",
    map: true,
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :key, 1, type: :string
  field :value, 2, type: :string
end

defmodule Livekitex.Proto.Livekit.TokenSourceRequest do
  use Protobuf,
    full_name: "livekit.TokenSourceRequest",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :room_name, 1, proto3_optional: true, type: :string, json_name: "roomName"
  field :participant_name, 2, proto3_optional: true, type: :string, json_name: "participantName"

  field :participant_identity, 3,
    proto3_optional: true,
    type: :string,
    json_name: "participantIdentity"

  field :participant_metadata, 4,
    proto3_optional: true,
    type: :string,
    json_name: "participantMetadata"

  field :participant_attributes, 5,
    repeated: true,
    type: Livekitex.Proto.Livekit.TokenSourceRequest.ParticipantAttributesEntry,
    json_name: "participantAttributes",
    map: true

  field :room_config, 6,
    proto3_optional: true,
    type: Livekitex.Proto.Livekit.RoomConfiguration,
    json_name: "roomConfig"
end

defmodule Livekitex.Proto.Livekit.TokenSourceResponse do
  use Protobuf,
    full_name: "livekit.TokenSourceResponse",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :server_url, 1, type: :string, json_name: "serverUrl"
  field :participant_token, 2, type: :string, json_name: "participantToken", deprecated: false
end

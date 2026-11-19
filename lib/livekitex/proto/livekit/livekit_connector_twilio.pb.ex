defmodule Livekitex.Proto.Livekit.ConnectTwilioCallRequest.TwilioCallDirection do
  use Protobuf,
    enum: true,
    full_name: "livekit.ConnectTwilioCallRequest.TwilioCallDirection",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :TWILIO_CALL_DIRECTION_INBOUND, 0
  field :TWILIO_CALL_DIRECTION_OUTBOUND, 1
end

defmodule Livekitex.Proto.Livekit.ConnectTwilioCallRequest.ParticipantAttributesEntry do
  use Protobuf,
    full_name: "livekit.ConnectTwilioCallRequest.ParticipantAttributesEntry",
    map: true,
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :key, 1, type: :string
  field :value, 2, type: :string
end

defmodule Livekitex.Proto.Livekit.ConnectTwilioCallRequest do
  use Protobuf,
    full_name: "livekit.ConnectTwilioCallRequest",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :twilio_call_direction, 1,
    type: Livekitex.Proto.Livekit.ConnectTwilioCallRequest.TwilioCallDirection,
    json_name: "twilioCallDirection",
    enum: true

  field :room_name, 2, type: :string, json_name: "roomName"
  field :agents, 3, repeated: true, type: Livekitex.Proto.Livekit.RoomAgentDispatch
  field :participant_identity, 4, type: :string, json_name: "participantIdentity"
  field :participant_name, 5, type: :string, json_name: "participantName", deprecated: false

  field :participant_metadata, 6,
    type: :string,
    json_name: "participantMetadata",
    deprecated: false

  field :participant_attributes, 7,
    repeated: true,
    type: Livekitex.Proto.Livekit.ConnectTwilioCallRequest.ParticipantAttributesEntry,
    json_name: "participantAttributes",
    map: true,
    deprecated: false

  field :destination_country, 8, type: :string, json_name: "destinationCountry"
end

defmodule Livekitex.Proto.Livekit.ConnectTwilioCallResponse do
  use Protobuf,
    full_name: "livekit.ConnectTwilioCallResponse",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :connect_url, 1, type: :string, json_name: "connectUrl"
end

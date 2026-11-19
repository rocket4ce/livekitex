defmodule Livekitex.Proto.Livekit.WhatsAppCallDirection do
  use Protobuf,
    enum: true,
    full_name: "livekit.WhatsAppCallDirection",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :WHATSAPP_CALL_DIRECTION_INBOUND, 0
  field :WHATSAPP_CALL_DIRECTION_OUTBOUND, 2
end

defmodule Livekitex.Proto.Livekit.DisconnectWhatsAppCallRequest.DisconnectReason do
  use Protobuf,
    enum: true,
    full_name: "livekit.DisconnectWhatsAppCallRequest.DisconnectReason",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :BUSINESS_INITIATED, 0
  field :USER_INITIATED, 1
end

defmodule Livekitex.Proto.Livekit.DialWhatsAppCallRequest.ParticipantAttributesEntry do
  use Protobuf,
    full_name: "livekit.DialWhatsAppCallRequest.ParticipantAttributesEntry",
    map: true,
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :key, 1, type: :string
  field :value, 2, type: :string
end

defmodule Livekitex.Proto.Livekit.DialWhatsAppCallRequest do
  use Protobuf,
    full_name: "livekit.DialWhatsAppCallRequest",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :whatsapp_phone_number_id, 1,
    type: :string,
    json_name: "whatsappPhoneNumberId",
    deprecated: false

  field :whatsapp_to_phone_number, 2,
    type: :string,
    json_name: "whatsappToPhoneNumber",
    deprecated: false

  field :whatsapp_api_key, 3, type: :string, json_name: "whatsappApiKey", deprecated: false
  field :whatsapp_cloud_api_version, 12, type: :string, json_name: "whatsappCloudApiVersion"

  field :whatsapp_biz_opaque_callback_data, 4,
    type: :string,
    json_name: "whatsappBizOpaqueCallbackData"

  field :room_name, 5, type: :string, json_name: "roomName"
  field :agents, 6, repeated: true, type: Livekitex.Proto.Livekit.RoomAgentDispatch
  field :participant_identity, 7, type: :string, json_name: "participantIdentity"
  field :participant_name, 8, type: :string, json_name: "participantName", deprecated: false

  field :participant_metadata, 9,
    type: :string,
    json_name: "participantMetadata",
    deprecated: false

  field :participant_attributes, 10,
    repeated: true,
    type: Livekitex.Proto.Livekit.DialWhatsAppCallRequest.ParticipantAttributesEntry,
    json_name: "participantAttributes",
    map: true,
    deprecated: false

  field :destination_country, 11, type: :string, json_name: "destinationCountry"
  field :ringing_timeout, 13, type: Google.Protobuf.Duration, json_name: "ringingTimeout"
end

defmodule Livekitex.Proto.Livekit.DialWhatsAppCallResponse do
  use Protobuf,
    full_name: "livekit.DialWhatsAppCallResponse",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :whatsapp_call_id, 1, type: :string, json_name: "whatsappCallId", deprecated: false
  field :room_name, 2, type: :string, json_name: "roomName"
end

defmodule Livekitex.Proto.Livekit.DisconnectWhatsAppCallRequest do
  use Protobuf,
    full_name: "livekit.DisconnectWhatsAppCallRequest",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :whatsapp_call_id, 1, type: :string, json_name: "whatsappCallId", deprecated: false
  field :whatsapp_api_key, 2, type: :string, json_name: "whatsappApiKey", deprecated: false

  field :disconnect_reason, 3,
    type: Livekitex.Proto.Livekit.DisconnectWhatsAppCallRequest.DisconnectReason,
    json_name: "disconnectReason",
    enum: true
end

defmodule Livekitex.Proto.Livekit.DisconnectWhatsAppCallResponse do
  use Protobuf,
    full_name: "livekit.DisconnectWhatsAppCallResponse",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3
end

defmodule Livekitex.Proto.Livekit.ConnectWhatsAppCallRequest do
  use Protobuf,
    full_name: "livekit.ConnectWhatsAppCallRequest",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :whatsapp_call_id, 1, type: :string, json_name: "whatsappCallId", deprecated: false
  field :sdp, 2, type: Livekitex.Proto.Livekit.SessionDescription
  field :wait_until_answered, 3, type: :bool, json_name: "waitUntilAnswered"
end

defmodule Livekitex.Proto.Livekit.ConnectWhatsAppCallResponse do
  use Protobuf,
    full_name: "livekit.ConnectWhatsAppCallResponse",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3
end

defmodule Livekitex.Proto.Livekit.AcceptWhatsAppCallRequest.ParticipantAttributesEntry do
  use Protobuf,
    full_name: "livekit.AcceptWhatsAppCallRequest.ParticipantAttributesEntry",
    map: true,
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :key, 1, type: :string
  field :value, 2, type: :string
end

defmodule Livekitex.Proto.Livekit.AcceptWhatsAppCallRequest do
  use Protobuf,
    full_name: "livekit.AcceptWhatsAppCallRequest",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :whatsapp_phone_number_id, 1,
    type: :string,
    json_name: "whatsappPhoneNumberId",
    deprecated: false

  field :whatsapp_api_key, 2, type: :string, json_name: "whatsappApiKey", deprecated: false
  field :whatsapp_cloud_api_version, 13, type: :string, json_name: "whatsappCloudApiVersion"
  field :whatsapp_call_id, 3, type: :string, json_name: "whatsappCallId", deprecated: false

  field :whatsapp_biz_opaque_callback_data, 4,
    type: :string,
    json_name: "whatsappBizOpaqueCallbackData"

  field :sdp, 5, type: Livekitex.Proto.Livekit.SessionDescription
  field :room_name, 6, type: :string, json_name: "roomName"
  field :agents, 7, repeated: true, type: Livekitex.Proto.Livekit.RoomAgentDispatch
  field :participant_identity, 8, type: :string, json_name: "participantIdentity"
  field :participant_name, 9, type: :string, json_name: "participantName", deprecated: false

  field :participant_metadata, 10,
    type: :string,
    json_name: "participantMetadata",
    deprecated: false

  field :participant_attributes, 11,
    repeated: true,
    type: Livekitex.Proto.Livekit.AcceptWhatsAppCallRequest.ParticipantAttributesEntry,
    json_name: "participantAttributes",
    map: true,
    deprecated: false

  field :destination_country, 12, type: :string, json_name: "destinationCountry"
  field :ringing_timeout, 14, type: Google.Protobuf.Duration, json_name: "ringingTimeout"
  field :wait_until_answered, 15, type: :bool, json_name: "waitUntilAnswered"
end

defmodule Livekitex.Proto.Livekit.AcceptWhatsAppCallResponse do
  use Protobuf,
    full_name: "livekit.AcceptWhatsAppCallResponse",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :room_name, 1, type: :string, json_name: "roomName"
end

defmodule Livekitex.Proto.Livekit.WhatsAppCall do
  use Protobuf,
    full_name: "livekit.WhatsAppCall",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :whatsapp_call_id, 1, type: :string, json_name: "whatsappCallId", deprecated: false
  field :direction, 2, type: Livekitex.Proto.Livekit.WhatsAppCallDirection, enum: true
end

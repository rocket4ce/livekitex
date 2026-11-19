defmodule Livekitex.Proto.Livekit.ConnectorType do
  use Protobuf,
    enum: true,
    full_name: "livekit.ConnectorType",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :Unspecified, 0
  field :WhatsApp, 1
  field :Twilio, 2
end

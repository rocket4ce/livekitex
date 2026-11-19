defmodule Livekitex.Proto.Logger.Sensitivity do
  use Protobuf,
    enum: true,
    full_name: "logger.Sensitivity",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :SENSITIVITY_UNSPECIFIED, 0
  field :SENSITIVITY_PII, 1
  field :SENSITIVITY_SECRET, 2
end

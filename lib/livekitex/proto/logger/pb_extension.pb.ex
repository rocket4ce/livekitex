defmodule Livekitex.Proto.Logger.PbExtension do
  use Protobuf, protoc_gen_elixir_version: "0.17.1"

  extend Google.Protobuf.FieldOptions, :redact_format, 1286,
    optional: true,
    type: :string,
    json_name: "redactFormat"

  extend Google.Protobuf.FieldOptions, :name, 1287, optional: true, type: :string

  extend Google.Protobuf.FieldOptions, :sensitivity, 1288,
    optional: true,
    type: Livekitex.Proto.Logger.Sensitivity,
    enum: true
end

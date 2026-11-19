defmodule Livekitex.Proto.Livekit.PhoneNumberStatus do
  @moduledoc """
  Phone number status enumeration
  """

  use Protobuf,
    enum: true,
    full_name: "livekit.PhoneNumberStatus",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :PHONE_NUMBER_STATUS_UNSPECIFIED, 0
  field :PHONE_NUMBER_STATUS_ACTIVE, 1
  field :PHONE_NUMBER_STATUS_PENDING, 2
  field :PHONE_NUMBER_STATUS_RELEASED, 3
  field :PHONE_NUMBER_STATUS_OFFLINE, 4
end

defmodule Livekitex.Proto.Livekit.PhoneNumberInboundStatus do
  use Protobuf,
    enum: true,
    full_name: "livekit.PhoneNumberInboundStatus",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :PHONE_NUMBER_IN_STATUS_UNSPECIFIED, 0
  field :PHONE_NUMBER_IN_STATUS_ACTIVE, 1
  field :PHONE_NUMBER_IN_STATUS_UNAVAILABLE, 2
  field :PHONE_NUMBER_IN_STATUS_DETACHED, 3
end

defmodule Livekitex.Proto.Livekit.PhoneNumberOutboundStatus do
  use Protobuf,
    enum: true,
    full_name: "livekit.PhoneNumberOutboundStatus",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :PHONE_NUMBER_OUT_STATUS_UNSPECIFIED, 0
  field :PHONE_NUMBER_OUT_STATUS_ACTIVE, 1
  field :PHONE_NUMBER_OUT_STATUS_UNAVAILABLE, 2
end

defmodule Livekitex.Proto.Livekit.PhoneNumberType do
  @moduledoc """
  Phone number type enumeration
  """

  use Protobuf,
    enum: true,
    full_name: "livekit.PhoneNumberType",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :PHONE_NUMBER_TYPE_UNKNOWN, 0
  field :PHONE_NUMBER_TYPE_MOBILE, 1
  field :PHONE_NUMBER_TYPE_LOCAL, 2
  field :PHONE_NUMBER_TYPE_TOLL_FREE, 3
end

defmodule Livekitex.Proto.Livekit.SearchPhoneNumbersRequest do
  @moduledoc """
  SearchPhoneNumbersRequest - Request to search available phone numbers
  """

  use Protobuf,
    full_name: "livekit.SearchPhoneNumbersRequest",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :country_code, 1, type: :string, json_name: "countryCode"
  field :area_code, 2, proto3_optional: true, type: :string, json_name: "areaCode"
  field :limit, 3, proto3_optional: true, type: :int32

  field :page_token, 4,
    proto3_optional: true,
    type: Livekitex.Proto.Livekit.TokenPagination,
    json_name: "pageToken"
end

defmodule Livekitex.Proto.Livekit.SearchPhoneNumbersResponse do
  @moduledoc """
  SearchPhoneNumbersResponse - Response containing available phone numbers
  """

  use Protobuf,
    full_name: "livekit.SearchPhoneNumbersResponse",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :items, 1, repeated: true, type: Livekitex.Proto.Livekit.PhoneNumber

  field :next_page_token, 2,
    type: Livekitex.Proto.Livekit.TokenPagination,
    json_name: "nextPageToken"
end

defmodule Livekitex.Proto.Livekit.PurchasePhoneNumberRequest do
  @moduledoc """
  PurchasePhoneNumberRequest - Request to purchase phone numbers
  """

  use Protobuf,
    full_name: "livekit.PurchasePhoneNumberRequest",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :phone_numbers, 1, repeated: true, type: :string, json_name: "phoneNumbers"

  field :sip_dispatch_rule_id, 2,
    proto3_optional: true,
    type: :string,
    json_name: "sipDispatchRuleId",
    deprecated: false
end

defmodule Livekitex.Proto.Livekit.PurchasePhoneNumberResponse do
  @moduledoc """
  PurchasePhoneNumberResponse - Response containing the purchased phone numbers
  """

  use Protobuf,
    full_name: "livekit.PurchasePhoneNumberResponse",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :phone_numbers, 1,
    repeated: true,
    type: Livekitex.Proto.Livekit.PhoneNumber,
    json_name: "phoneNumbers"
end

defmodule Livekitex.Proto.Livekit.ListPhoneNumbersRequest do
  @moduledoc """
  ListPhoneNumbersRequest - Request to list phone numbers
  """

  use Protobuf,
    full_name: "livekit.ListPhoneNumbersRequest",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :limit, 1, proto3_optional: true, type: :int32
  field :statuses, 2, repeated: true, type: Livekitex.Proto.Livekit.PhoneNumberStatus, enum: true

  field :page_token, 3,
    proto3_optional: true,
    type: Livekitex.Proto.Livekit.TokenPagination,
    json_name: "pageToken"

  field :sip_dispatch_rule_id, 4,
    proto3_optional: true,
    type: :string,
    json_name: "sipDispatchRuleId",
    deprecated: false
end

defmodule Livekitex.Proto.Livekit.ListPhoneNumbersResponse do
  @moduledoc """
  ListPhoneNumbersResponse - Response containing phone numbers
  """

  use Protobuf,
    full_name: "livekit.ListPhoneNumbersResponse",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :items, 1, repeated: true, type: Livekitex.Proto.Livekit.PhoneNumber

  field :next_page_token, 2,
    type: Livekitex.Proto.Livekit.TokenPagination,
    json_name: "nextPageToken"

  field :total_count, 3, type: :int32, json_name: "totalCount"
  field :offline_count, 4, type: :int32, json_name: "offlineCount"
end

defmodule Livekitex.Proto.Livekit.GetPhoneNumberRequest do
  @moduledoc """
  GetPhoneNumberRequest - Request to get a phone number
  """

  use Protobuf,
    full_name: "livekit.GetPhoneNumberRequest",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :id, 1, proto3_optional: true, type: :string
  field :phone_number, 2, proto3_optional: true, type: :string, json_name: "phoneNumber"
end

defmodule Livekitex.Proto.Livekit.GetPhoneNumberResponse do
  @moduledoc """
  GetPhoneNumberResponse - Response containing the phone number
  """

  use Protobuf,
    full_name: "livekit.GetPhoneNumberResponse",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :phone_number, 1, type: Livekitex.Proto.Livekit.PhoneNumber, json_name: "phoneNumber"
end

defmodule Livekitex.Proto.Livekit.UpdatePhoneNumberRequest do
  @moduledoc """
  UpdatePhoneNumberRequest - Request to update a phone number
  """

  use Protobuf,
    full_name: "livekit.UpdatePhoneNumberRequest",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :id, 1, proto3_optional: true, type: :string
  field :phone_number, 2, proto3_optional: true, type: :string, json_name: "phoneNumber"

  field :sip_dispatch_rule_id, 3,
    proto3_optional: true,
    type: :string,
    json_name: "sipDispatchRuleId",
    deprecated: false

  field :name, 4, proto3_optional: true, type: :string
end

defmodule Livekitex.Proto.Livekit.UpdatePhoneNumberResponse do
  @moduledoc """
  UpdatePhoneNumberResponse - Response containing the updated phone number
  """

  use Protobuf,
    full_name: "livekit.UpdatePhoneNumberResponse",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :phone_number, 1, type: Livekitex.Proto.Livekit.PhoneNumber, json_name: "phoneNumber"
end

defmodule Livekitex.Proto.Livekit.ReleasePhoneNumbersRequest do
  @moduledoc """
  ReleasePhoneNumbersRequest - Request to release phone numbers
  """

  use Protobuf,
    full_name: "livekit.ReleasePhoneNumbersRequest",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :ids, 1, repeated: true, type: :string
  field :phone_numbers, 2, repeated: true, type: :string, json_name: "phoneNumbers"
end

defmodule Livekitex.Proto.Livekit.ReleasePhoneNumbersResponse do
  @moduledoc """
  ReleasePhoneNumbersResponse - Response for releasing phone numbers
  Empty response - operation completed successfully
  """

  use Protobuf,
    full_name: "livekit.ReleasePhoneNumbersResponse",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3
end

defmodule Livekitex.Proto.Livekit.PhoneNumber do
  @moduledoc """
  PhoneNumber - Unified phone number type for inventory and purchased numbers
  """

  use Protobuf,
    full_name: "livekit.PhoneNumber",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :id, 1, type: :string
  field :name, 17, type: :string
  field :e164_format, 2, type: :string, json_name: "e164Format"
  field :country_code, 3, type: :string, json_name: "countryCode"
  field :area_code, 4, type: :string, json_name: "areaCode"

  field :number_type, 5,
    type: Livekitex.Proto.Livekit.PhoneNumberType,
    json_name: "numberType",
    enum: true

  field :locality, 6, type: :string
  field :region, 7, type: :string
  field :spam_score, 8, type: :double, json_name: "spamScore"
  field :created_at, 9, type: Google.Protobuf.Timestamp, json_name: "createdAt"
  field :updated_at, 10, type: Google.Protobuf.Timestamp, json_name: "updatedAt"
  field :capabilities, 11, repeated: true, type: :string
  field :status, 12, type: Livekitex.Proto.Livekit.PhoneNumberStatus, enum: true

  field :inbound_status, 18,
    type: Livekitex.Proto.Livekit.PhoneNumberInboundStatus,
    json_name: "inboundStatus",
    enum: true

  field :outbound_status, 19,
    type: Livekitex.Proto.Livekit.PhoneNumberOutboundStatus,
    json_name: "outboundStatus",
    enum: true

  field :assigned_at, 13, type: Google.Protobuf.Timestamp, json_name: "assignedAt"
  field :released_at, 14, type: Google.Protobuf.Timestamp, json_name: "releasedAt"
  field :sip_dispatch_rule_id, 15, type: :string, json_name: "sipDispatchRuleId", deprecated: true
  field :sip_dispatch_rule_ids, 16, repeated: true, type: :string, json_name: "sipDispatchRuleIds"
end

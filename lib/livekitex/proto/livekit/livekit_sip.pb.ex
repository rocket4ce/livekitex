defmodule Livekitex.Proto.Livekit.SIPStatusCode do
  use Protobuf,
    enum: true,
    full_name: "livekit.SIPStatusCode",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :SIP_STATUS_UNKNOWN, 0
  field :SIP_STATUS_TRYING, 100
  field :SIP_STATUS_RINGING, 180
  field :SIP_STATUS_CALL_IS_FORWARDED, 181
  field :SIP_STATUS_QUEUED, 182
  field :SIP_STATUS_SESSION_PROGRESS, 183
  field :SIP_STATUS_EARLY_DIALOG_TERMINATED, 199
  field :SIP_STATUS_OK, 200
  field :SIP_STATUS_ACCEPTED, 202
  field :SIP_STATUS_NO_NOTIFICATION, 204
  field :SIP_STATUS_MULTIPLE_CHOICES, 300
  field :SIP_STATUS_MOVED_PERMANENTLY, 301
  field :SIP_STATUS_MOVED_TEMPORARILY, 302
  field :SIP_STATUS_USE_PROXY, 305
  field :SIP_STATUS_ALTERNATIVE_SERVICE, 380
  field :SIP_STATUS_BAD_REQUEST, 400
  field :SIP_STATUS_UNAUTHORIZED, 401
  field :SIP_STATUS_PAYMENT_REQUIRED, 402
  field :SIP_STATUS_FORBIDDEN, 403
  field :SIP_STATUS_NOTFOUND, 404
  field :SIP_STATUS_METHOD_NOT_ALLOWED, 405
  field :SIP_STATUS_NOT_ACCEPTABLE, 406
  field :SIP_STATUS_PROXY_AUTH_REQUIRED, 407
  field :SIP_STATUS_REQUEST_TIMEOUT, 408
  field :SIP_STATUS_CONFLICT, 409
  field :SIP_STATUS_GONE, 410
  field :SIP_STATUS_LENGTH_REQUIRED, 411
  field :SIP_STATUS_CONDITIONAL_REQUEST_FAILED, 412
  field :SIP_STATUS_REQUEST_ENTITY_TOO_LARGE, 413
  field :SIP_STATUS_REQUEST_URI_TOO_LONG, 414
  field :SIP_STATUS_UNSUPPORTED_MEDIA_TYPE, 415
  field :SIP_STATUS_REQUESTED_RANGE_NOT_SATISFIABLE, 416
  field :SIP_STATUS_UNKNOWN_RESOURCE_PRIORITY, 417
  field :SIP_STATUS_BAD_EXTENSION, 420
  field :SIP_STATUS_EXTENSION_REQUIRED, 421
  field :SIP_STATUS_SESSION_INTERVAL_TOO_SMALL, 422
  field :SIP_STATUS_INTERVAL_TOO_BRIEF, 423
  field :SIP_STATUS_BAD_LOCATION_INFORMATION, 424
  field :SIP_STATUS_BAD_ALERT_MESSAGE, 425
  field :SIP_STATUS_USE_IDENTITY_HEADER, 428
  field :SIP_STATUS_PROVIDE_REFERRER_IDENTITY, 429
  field :SIP_STATUS_FLOW_FAILED, 430
  field :SIP_STATUS_ANONYMITY_DISALLOWED, 433
  field :SIP_STATUS_BAD_IDENTITY_INFO, 436
  field :SIP_STATUS_UNSUPPORTED_CERTIFICATE, 437
  field :SIP_STATUS_INVALID_IDENTITY_HEADER, 438
  field :SIP_STATUS_FIRST_HOP_LACKS_OUTBOUND_SUPPORT, 439
  field :SIP_STATUS_MAX_BREADTH_EXCEEDED, 440
  field :SIP_STATUS_BAD_INFO_PACKAGE, 469
  field :SIP_STATUS_CONSENT_NEEDED, 470
  field :SIP_STATUS_TEMPORARILY_UNAVAILABLE, 480
  field :SIP_STATUS_CALL_TRANSACTION_DOES_NOT_EXISTS, 481
  field :SIP_STATUS_LOOP_DETECTED, 482
  field :SIP_STATUS_TOO_MANY_HOPS, 483
  field :SIP_STATUS_ADDRESS_INCOMPLETE, 484
  field :SIP_STATUS_AMBIGUOUS, 485
  field :SIP_STATUS_BUSY_HERE, 486
  field :SIP_STATUS_REQUEST_TERMINATED, 487
  field :SIP_STATUS_NOT_ACCEPTABLE_HERE, 488
  field :SIP_STATUS_BAD_EVENT, 489
  field :SIP_STATUS_REQUEST_PENDING, 491
  field :SIP_STATUS_UNDECIPHERABLE, 493
  field :SIP_STATUS_SECURITY_AGREEMENT_REQUIRED, 494
  field :SIP_STATUS_INTERNAL_SERVER_ERROR, 500
  field :SIP_STATUS_NOT_IMPLEMENTED, 501
  field :SIP_STATUS_BAD_GATEWAY, 502
  field :SIP_STATUS_SERVICE_UNAVAILABLE, 503
  field :SIP_STATUS_GATEWAY_TIMEOUT, 504
  field :SIP_STATUS_VERSION_NOT_SUPPORTED, 505
  field :SIP_STATUS_MESSAGE_TOO_LARGE, 513
  field :SIP_STATUS_GLOBAL_BUSY_EVERYWHERE, 600
  field :SIP_STATUS_GLOBAL_DECLINE, 603
  field :SIP_STATUS_GLOBAL_DOES_NOT_EXIST_ANYWHERE, 604
  field :SIP_STATUS_GLOBAL_NOT_ACCEPTABLE, 606
  field :SIP_STATUS_GLOBAL_UNWANTED, 607
  field :SIP_STATUS_GLOBAL_REJECTED, 608
end

defmodule Livekitex.Proto.Livekit.SIPTransport do
  use Protobuf,
    enum: true,
    full_name: "livekit.SIPTransport",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :SIP_TRANSPORT_AUTO, 0
  field :SIP_TRANSPORT_UDP, 1
  field :SIP_TRANSPORT_TCP, 2
  field :SIP_TRANSPORT_TLS, 3
end

defmodule Livekitex.Proto.Livekit.SIPHeaderOptions do
  use Protobuf,
    enum: true,
    full_name: "livekit.SIPHeaderOptions",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :SIP_NO_HEADERS, 0
  field :SIP_X_HEADERS, 1
  field :SIP_ALL_HEADERS, 2
end

defmodule Livekitex.Proto.Livekit.SIPMediaEncryption do
  use Protobuf,
    enum: true,
    full_name: "livekit.SIPMediaEncryption",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :SIP_MEDIA_ENCRYPT_DISABLE, 0
  field :SIP_MEDIA_ENCRYPT_ALLOW, 1
  field :SIP_MEDIA_ENCRYPT_REQUIRE, 2
end

defmodule Livekitex.Proto.Livekit.SIPDialtone do
  @moduledoc """
  Dial tone (ringback) played while a call is being placed or transferred.
  Receivers treat unknown values as SIP_DIALTONE_ETSI.
  """

  use Protobuf,
    enum: true,
    full_name: "livekit.SIPDialtone",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :SIP_DIALTONE_DISABLED, 0
  field :SIP_DIALTONE_ETSI, 1
  field :SIP_DIALTONE_AUTO, 2
  field :SIP_DIALTONE_US, 3
  field :SIP_DIALTONE_UK, 4
  field :SIP_DIALTONE_JP, 5
  field :SIP_DIALTONE_AU, 6
end

defmodule Livekitex.Proto.Livekit.ProviderType do
  use Protobuf,
    enum: true,
    full_name: "livekit.ProviderType",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :PROVIDER_TYPE_UNKNOWN, 0
  field :PROVIDER_TYPE_INTERNAL, 1
  field :PROVIDER_TYPE_EXTERNAL, 2
end

defmodule Livekitex.Proto.Livekit.SIPCallStatus do
  use Protobuf,
    enum: true,
    full_name: "livekit.SIPCallStatus",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :SCS_CALL_INCOMING, 0
  field :SCS_PARTICIPANT_JOINED, 1
  field :SCS_ACTIVE, 2
  field :SCS_DISCONNECTED, 3
  field :SCS_ERROR, 4
end

defmodule Livekitex.Proto.Livekit.SIPTransferStatus do
  use Protobuf,
    enum: true,
    full_name: "livekit.SIPTransferStatus",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :STS_TRANSFER_ONGOING, 0
  field :STS_TRANSFER_FAILED, 1
  field :STS_TRANSFER_SUCCESSFUL, 2
end

defmodule Livekitex.Proto.Livekit.SIPTransferReason do
  use Protobuf,
    enum: true,
    full_name: "livekit.SIPTransferReason",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :STR_UNSPECIFIED, 0
  field :STR_COMPLETED, 1
  field :STR_CALL_ENDED, 2
  field :STR_REJECTED, 3
  field :STR_RINGING_TIMEOUT, 4
  field :STR_SUBSCRIPTION_TERMINATED, 5
  field :STR_CANCELED, 6
end

defmodule Livekitex.Proto.Livekit.SIPFeature do
  use Protobuf,
    enum: true,
    full_name: "livekit.SIPFeature",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :NONE, 0
  field :KRISP_ENABLED, 1
end

defmodule Livekitex.Proto.Livekit.SIPCallDirection do
  use Protobuf,
    enum: true,
    full_name: "livekit.SIPCallDirection",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :SCD_UNKNOWN, 0
  field :SCD_INBOUND, 1
  field :SCD_OUTBOUND, 2
end

defmodule Livekitex.Proto.Livekit.SIPTrunkInfo.TrunkKind do
  use Protobuf,
    enum: true,
    full_name: "livekit.SIPTrunkInfo.TrunkKind",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :TRUNK_LEGACY, 0
  field :TRUNK_INBOUND, 1
  field :TRUNK_OUTBOUND, 2
end

defmodule Livekitex.Proto.Livekit.SIPStatus do
  @moduledoc """
  SIPStatus is returned as an error detail in CreateSIPParticipant.
  """

  use Protobuf,
    full_name: "livekit.SIPStatus",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :code, 1, type: Livekitex.Proto.Livekit.SIPStatusCode, enum: true
  field :status, 2, type: :string
end

defmodule Livekitex.Proto.Livekit.CreateSIPTrunkRequest do
  use Protobuf,
    deprecated: true,
    full_name: "livekit.CreateSIPTrunkRequest",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :inbound_addresses, 1, repeated: true, type: :string, json_name: "inboundAddresses"
  field :outbound_address, 2, type: :string, json_name: "outboundAddress"
  field :outbound_number, 3, type: :string, json_name: "outboundNumber"

  field :inbound_numbers_regex, 4,
    repeated: true,
    type: :string,
    json_name: "inboundNumbersRegex",
    deprecated: true

  field :inbound_numbers, 9, repeated: true, type: :string, json_name: "inboundNumbers"
  field :inbound_username, 5, type: :string, json_name: "inboundUsername", deprecated: false
  field :inbound_password, 6, type: :string, json_name: "inboundPassword", deprecated: false
  field :outbound_username, 7, type: :string, json_name: "outboundUsername", deprecated: false
  field :outbound_password, 8, type: :string, json_name: "outboundPassword", deprecated: false
  field :name, 10, type: :string
  field :metadata, 11, type: :string, deprecated: false
end

defmodule Livekitex.Proto.Livekit.SIPCodec do
  use Protobuf,
    full_name: "livekit.SIPCodec",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :name, 1, type: :string
  field :rate, 2, type: :uint32
end

defmodule Livekitex.Proto.Livekit.SIPMediaConfig do
  use Protobuf,
    full_name: "livekit.SIPMediaConfig",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :only_listed_codecs, 1, type: :bool, json_name: "onlyListedCodecs"
  field :codecs, 2, repeated: true, type: Livekitex.Proto.Livekit.SIPCodec

  field :encryption, 3,
    proto3_optional: true,
    type: Livekitex.Proto.Livekit.SIPMediaEncryption,
    enum: true

  field :media_timeout, 4,
    proto3_optional: true,
    type: Google.Protobuf.Duration,
    json_name: "mediaTimeout"

  field :drop_audio_during_dtmf, 5, type: :bool, json_name: "dropAudioDuringDtmf"
end

defmodule Livekitex.Proto.Livekit.ProviderInfo do
  use Protobuf,
    full_name: "livekit.ProviderInfo",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :id, 1, type: :string
  field :name, 2, type: :string
  field :type, 3, type: Livekitex.Proto.Livekit.ProviderType, enum: true
  field :prevent_transfer, 4, type: :bool, json_name: "preventTransfer"
end

defmodule Livekitex.Proto.Livekit.SIPTrunkInfo do
  use Protobuf,
    deprecated: true,
    full_name: "livekit.SIPTrunkInfo",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :sip_trunk_id, 1, type: :string, json_name: "sipTrunkId", deprecated: false
  field :kind, 14, type: Livekitex.Proto.Livekit.SIPTrunkInfo.TrunkKind, enum: true
  field :inbound_addresses, 2, repeated: true, type: :string, json_name: "inboundAddresses"
  field :outbound_address, 3, type: :string, json_name: "outboundAddress"
  field :outbound_number, 4, type: :string, json_name: "outboundNumber"
  field :transport, 13, type: Livekitex.Proto.Livekit.SIPTransport, enum: true

  field :inbound_numbers_regex, 5,
    repeated: true,
    type: :string,
    json_name: "inboundNumbersRegex",
    deprecated: true

  field :inbound_numbers, 10, repeated: true, type: :string, json_name: "inboundNumbers"
  field :inbound_username, 6, type: :string, json_name: "inboundUsername", deprecated: false
  field :inbound_password, 7, type: :string, json_name: "inboundPassword", deprecated: false
  field :outbound_username, 8, type: :string, json_name: "outboundUsername", deprecated: false
  field :outbound_password, 9, type: :string, json_name: "outboundPassword", deprecated: false
  field :name, 11, type: :string
  field :metadata, 12, type: :string, deprecated: false
end

defmodule Livekitex.Proto.Livekit.CreateSIPInboundTrunkRequest do
  use Protobuf,
    full_name: "livekit.CreateSIPInboundTrunkRequest",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :trunk, 1, type: Livekitex.Proto.Livekit.SIPInboundTrunkInfo
end

defmodule Livekitex.Proto.Livekit.UpdateSIPInboundTrunkRequest do
  use Protobuf,
    full_name: "livekit.UpdateSIPInboundTrunkRequest",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  oneof :action, 0

  field :sip_trunk_id, 1, type: :string, json_name: "sipTrunkId", deprecated: false
  field :replace, 2, type: Livekitex.Proto.Livekit.SIPInboundTrunkInfo, oneof: 0
  field :update, 3, type: Livekitex.Proto.Livekit.SIPInboundTrunkUpdate, oneof: 0
end

defmodule Livekitex.Proto.Livekit.SIPInboundTrunkInfo.HeadersEntry do
  use Protobuf,
    full_name: "livekit.SIPInboundTrunkInfo.HeadersEntry",
    map: true,
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :key, 1, type: :string
  field :value, 2, type: :string
end

defmodule Livekitex.Proto.Livekit.SIPInboundTrunkInfo.HeadersToAttributesEntry do
  use Protobuf,
    full_name: "livekit.SIPInboundTrunkInfo.HeadersToAttributesEntry",
    map: true,
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :key, 1, type: :string
  field :value, 2, type: :string
end

defmodule Livekitex.Proto.Livekit.SIPInboundTrunkInfo.AttributesToHeadersEntry do
  use Protobuf,
    full_name: "livekit.SIPInboundTrunkInfo.AttributesToHeadersEntry",
    map: true,
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :key, 1, type: :string
  field :value, 2, type: :string
end

defmodule Livekitex.Proto.Livekit.SIPInboundTrunkInfo do
  use Protobuf,
    full_name: "livekit.SIPInboundTrunkInfo",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :sip_trunk_id, 1, type: :string, json_name: "sipTrunkId", deprecated: false
  field :name, 2, type: :string
  field :metadata, 3, type: :string, deprecated: false
  field :numbers, 4, repeated: true, type: :string
  field :allowed_addresses, 5, repeated: true, type: :string, json_name: "allowedAddresses"
  field :allowed_numbers, 6, repeated: true, type: :string, json_name: "allowedNumbers"
  field :auth_username, 7, type: :string, json_name: "authUsername", deprecated: false
  field :auth_password, 8, type: :string, json_name: "authPassword", deprecated: false
  field :auth_realm, 19, type: :string, json_name: "authRealm"

  field :headers, 9,
    repeated: true,
    type: Livekitex.Proto.Livekit.SIPInboundTrunkInfo.HeadersEntry,
    map: true,
    deprecated: false

  field :headers_to_attributes, 10,
    repeated: true,
    type: Livekitex.Proto.Livekit.SIPInboundTrunkInfo.HeadersToAttributesEntry,
    json_name: "headersToAttributes",
    map: true

  field :attributes_to_headers, 14,
    repeated: true,
    type: Livekitex.Proto.Livekit.SIPInboundTrunkInfo.AttributesToHeadersEntry,
    json_name: "attributesToHeaders",
    map: true

  field :include_headers, 15,
    type: Livekitex.Proto.Livekit.SIPHeaderOptions,
    json_name: "includeHeaders",
    enum: true

  field :ringing_timeout, 11, type: Google.Protobuf.Duration, json_name: "ringingTimeout"

  field :ringing_timeout_status, 21,
    type: Livekitex.Proto.Livekit.SIPStatusCode,
    json_name: "ringingTimeoutStatus",
    enum: true

  field :max_call_duration, 12, type: Google.Protobuf.Duration, json_name: "maxCallDuration"
  field :krisp_enabled, 13, type: :bool, json_name: "krispEnabled"

  field :media_encryption, 16,
    type: Livekitex.Proto.Livekit.SIPMediaEncryption,
    json_name: "mediaEncryption",
    enum: true,
    deprecated: true

  field :media, 20, type: Livekitex.Proto.Livekit.SIPMediaConfig
  field :created_at, 17, type: Google.Protobuf.Timestamp, json_name: "createdAt"
  field :updated_at, 18, type: Google.Protobuf.Timestamp, json_name: "updatedAt"
end

defmodule Livekitex.Proto.Livekit.SIPInboundTrunkUpdate do
  use Protobuf,
    full_name: "livekit.SIPInboundTrunkUpdate",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :numbers, 1, type: Livekitex.Proto.Livekit.ListUpdate

  field :allowed_addresses, 2,
    type: Livekitex.Proto.Livekit.ListUpdate,
    json_name: "allowedAddresses"

  field :allowed_numbers, 3, type: Livekitex.Proto.Livekit.ListUpdate, json_name: "allowedNumbers"

  field :auth_username, 4,
    proto3_optional: true,
    type: :string,
    json_name: "authUsername",
    deprecated: false

  field :auth_password, 5,
    proto3_optional: true,
    type: :string,
    json_name: "authPassword",
    deprecated: false

  field :auth_realm, 9, proto3_optional: true, type: :string, json_name: "authRealm"
  field :name, 6, proto3_optional: true, type: :string
  field :metadata, 7, proto3_optional: true, type: :string, deprecated: false

  field :media_encryption, 8,
    proto3_optional: true,
    type: Livekitex.Proto.Livekit.SIPMediaEncryption,
    json_name: "mediaEncryption",
    enum: true,
    deprecated: true

  field :media, 10, type: Livekitex.Proto.Livekit.SIPMediaConfig
end

defmodule Livekitex.Proto.Livekit.CreateSIPOutboundTrunkRequest do
  use Protobuf,
    full_name: "livekit.CreateSIPOutboundTrunkRequest",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :trunk, 1, type: Livekitex.Proto.Livekit.SIPOutboundTrunkInfo
end

defmodule Livekitex.Proto.Livekit.UpdateSIPOutboundTrunkRequest do
  use Protobuf,
    full_name: "livekit.UpdateSIPOutboundTrunkRequest",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  oneof :action, 0

  field :sip_trunk_id, 1, type: :string, json_name: "sipTrunkId", deprecated: false
  field :replace, 2, type: Livekitex.Proto.Livekit.SIPOutboundTrunkInfo, oneof: 0
  field :update, 3, type: Livekitex.Proto.Livekit.SIPOutboundTrunkUpdate, oneof: 0
end

defmodule Livekitex.Proto.Livekit.SIPOutboundTrunkInfo.HeadersEntry do
  use Protobuf,
    full_name: "livekit.SIPOutboundTrunkInfo.HeadersEntry",
    map: true,
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :key, 1, type: :string
  field :value, 2, type: :string
end

defmodule Livekitex.Proto.Livekit.SIPOutboundTrunkInfo.HeadersToAttributesEntry do
  use Protobuf,
    full_name: "livekit.SIPOutboundTrunkInfo.HeadersToAttributesEntry",
    map: true,
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :key, 1, type: :string
  field :value, 2, type: :string
end

defmodule Livekitex.Proto.Livekit.SIPOutboundTrunkInfo.AttributesToHeadersEntry do
  use Protobuf,
    full_name: "livekit.SIPOutboundTrunkInfo.AttributesToHeadersEntry",
    map: true,
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :key, 1, type: :string
  field :value, 2, type: :string
end

defmodule Livekitex.Proto.Livekit.SIPOutboundTrunkInfo do
  use Protobuf,
    full_name: "livekit.SIPOutboundTrunkInfo",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :sip_trunk_id, 1, type: :string, json_name: "sipTrunkId", deprecated: false
  field :name, 2, type: :string
  field :metadata, 3, type: :string, deprecated: false
  field :address, 4, type: :string
  field :destination_country, 14, type: :string, json_name: "destinationCountry"
  field :transport, 5, type: Livekitex.Proto.Livekit.SIPTransport, enum: true
  field :numbers, 6, repeated: true, type: :string
  field :auth_username, 7, type: :string, json_name: "authUsername", deprecated: false
  field :auth_password, 8, type: :string, json_name: "authPassword", deprecated: false

  field :headers, 9,
    repeated: true,
    type: Livekitex.Proto.Livekit.SIPOutboundTrunkInfo.HeadersEntry,
    map: true,
    deprecated: false

  field :headers_to_attributes, 10,
    repeated: true,
    type: Livekitex.Proto.Livekit.SIPOutboundTrunkInfo.HeadersToAttributesEntry,
    json_name: "headersToAttributes",
    map: true

  field :attributes_to_headers, 11,
    repeated: true,
    type: Livekitex.Proto.Livekit.SIPOutboundTrunkInfo.AttributesToHeadersEntry,
    json_name: "attributesToHeaders",
    map: true

  field :include_headers, 12,
    type: Livekitex.Proto.Livekit.SIPHeaderOptions,
    json_name: "includeHeaders",
    enum: true

  field :media_encryption, 13,
    type: Livekitex.Proto.Livekit.SIPMediaEncryption,
    json_name: "mediaEncryption",
    enum: true,
    deprecated: true

  field :media, 18, type: Livekitex.Proto.Livekit.SIPMediaConfig
  field :from_host, 15, type: :string, json_name: "fromHost"
  field :created_at, 16, type: Google.Protobuf.Timestamp, json_name: "createdAt"
  field :updated_at, 17, type: Google.Protobuf.Timestamp, json_name: "updatedAt"
end

defmodule Livekitex.Proto.Livekit.SIPOutboundTrunkUpdate do
  use Protobuf,
    full_name: "livekit.SIPOutboundTrunkUpdate",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :address, 1, proto3_optional: true, type: :string

  field :transport, 2,
    proto3_optional: true,
    type: Livekitex.Proto.Livekit.SIPTransport,
    enum: true

  field :destination_country, 9,
    proto3_optional: true,
    type: :string,
    json_name: "destinationCountry"

  field :numbers, 3, type: Livekitex.Proto.Livekit.ListUpdate

  field :auth_username, 4,
    proto3_optional: true,
    type: :string,
    json_name: "authUsername",
    deprecated: false

  field :auth_password, 5,
    proto3_optional: true,
    type: :string,
    json_name: "authPassword",
    deprecated: false

  field :name, 6, proto3_optional: true, type: :string
  field :metadata, 7, proto3_optional: true, type: :string, deprecated: false

  field :media_encryption, 8,
    proto3_optional: true,
    type: Livekitex.Proto.Livekit.SIPMediaEncryption,
    json_name: "mediaEncryption",
    enum: true,
    deprecated: true

  field :media, 11, type: Livekitex.Proto.Livekit.SIPMediaConfig
  field :from_host, 10, proto3_optional: true, type: :string, json_name: "fromHost"
end

defmodule Livekitex.Proto.Livekit.GetSIPInboundTrunkRequest do
  use Protobuf,
    full_name: "livekit.GetSIPInboundTrunkRequest",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :sip_trunk_id, 1, type: :string, json_name: "sipTrunkId", deprecated: false
end

defmodule Livekitex.Proto.Livekit.GetSIPInboundTrunkResponse do
  use Protobuf,
    full_name: "livekit.GetSIPInboundTrunkResponse",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :trunk, 1, type: Livekitex.Proto.Livekit.SIPInboundTrunkInfo
end

defmodule Livekitex.Proto.Livekit.GetSIPOutboundTrunkRequest do
  use Protobuf,
    full_name: "livekit.GetSIPOutboundTrunkRequest",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :sip_trunk_id, 1, type: :string, json_name: "sipTrunkId", deprecated: false
end

defmodule Livekitex.Proto.Livekit.GetSIPOutboundTrunkResponse do
  use Protobuf,
    full_name: "livekit.GetSIPOutboundTrunkResponse",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :trunk, 1, type: Livekitex.Proto.Livekit.SIPOutboundTrunkInfo
end

defmodule Livekitex.Proto.Livekit.ListSIPTrunkRequest do
  use Protobuf,
    deprecated: true,
    full_name: "livekit.ListSIPTrunkRequest",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :page, 1, type: Livekitex.Proto.Livekit.Pagination
end

defmodule Livekitex.Proto.Livekit.ListSIPTrunkResponse do
  use Protobuf,
    deprecated: true,
    full_name: "livekit.ListSIPTrunkResponse",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :items, 1, repeated: true, type: Livekitex.Proto.Livekit.SIPTrunkInfo
end

defmodule Livekitex.Proto.Livekit.ListSIPInboundTrunkRequest do
  @moduledoc """
  ListSIPInboundTrunkRequest lists inbound trunks for given filters. If no filters are set, all trunks are listed.
  """

  use Protobuf,
    full_name: "livekit.ListSIPInboundTrunkRequest",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :page, 3, type: Livekitex.Proto.Livekit.Pagination
  field :trunk_ids, 1, repeated: true, type: :string, json_name: "trunkIds"
  field :numbers, 2, repeated: true, type: :string
end

defmodule Livekitex.Proto.Livekit.ListSIPInboundTrunkResponse do
  use Protobuf,
    full_name: "livekit.ListSIPInboundTrunkResponse",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :items, 1, repeated: true, type: Livekitex.Proto.Livekit.SIPInboundTrunkInfo
end

defmodule Livekitex.Proto.Livekit.ListSIPOutboundTrunkRequest do
  @moduledoc """
  ListSIPOutboundTrunkRequest lists outbound trunks for given filters. If no filters are set, all trunks are listed.
  """

  use Protobuf,
    full_name: "livekit.ListSIPOutboundTrunkRequest",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :page, 3, type: Livekitex.Proto.Livekit.Pagination
  field :trunk_ids, 1, repeated: true, type: :string, json_name: "trunkIds"
  field :numbers, 2, repeated: true, type: :string
end

defmodule Livekitex.Proto.Livekit.ListSIPOutboundTrunkResponse do
  use Protobuf,
    full_name: "livekit.ListSIPOutboundTrunkResponse",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :items, 1, repeated: true, type: Livekitex.Proto.Livekit.SIPOutboundTrunkInfo
end

defmodule Livekitex.Proto.Livekit.DeleteSIPTrunkRequest do
  use Protobuf,
    full_name: "livekit.DeleteSIPTrunkRequest",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :sip_trunk_id, 1, type: :string, json_name: "sipTrunkId", deprecated: false
end

defmodule Livekitex.Proto.Livekit.SIPDispatchRuleDirect do
  use Protobuf,
    full_name: "livekit.SIPDispatchRuleDirect",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :room_name, 1, type: :string, json_name: "roomName"
  field :pin, 2, type: :string, deprecated: false
end

defmodule Livekitex.Proto.Livekit.SIPDispatchRuleIndividual do
  use Protobuf,
    full_name: "livekit.SIPDispatchRuleIndividual",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :room_prefix, 1, type: :string, json_name: "roomPrefix"
  field :pin, 2, type: :string, deprecated: false
  field :no_randomness, 3, type: :bool, json_name: "noRandomness"
end

defmodule Livekitex.Proto.Livekit.SIPDispatchRuleCallee do
  use Protobuf,
    full_name: "livekit.SIPDispatchRuleCallee",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :room_prefix, 1, type: :string, json_name: "roomPrefix"
  field :pin, 2, type: :string, deprecated: false
  field :randomize, 3, type: :bool
end

defmodule Livekitex.Proto.Livekit.SIPDispatchRule do
  use Protobuf,
    full_name: "livekit.SIPDispatchRule",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  oneof :rule, 0

  field :dispatch_rule_direct, 1,
    type: Livekitex.Proto.Livekit.SIPDispatchRuleDirect,
    json_name: "dispatchRuleDirect",
    oneof: 0

  field :dispatch_rule_individual, 2,
    type: Livekitex.Proto.Livekit.SIPDispatchRuleIndividual,
    json_name: "dispatchRuleIndividual",
    oneof: 0

  field :dispatch_rule_callee, 3,
    type: Livekitex.Proto.Livekit.SIPDispatchRuleCallee,
    json_name: "dispatchRuleCallee",
    oneof: 0
end

defmodule Livekitex.Proto.Livekit.CreateSIPDispatchRuleRequest.AttributesEntry do
  use Protobuf,
    full_name: "livekit.CreateSIPDispatchRuleRequest.AttributesEntry",
    map: true,
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :key, 1, type: :string
  field :value, 2, type: :string
end

defmodule Livekitex.Proto.Livekit.CreateSIPDispatchRuleRequest do
  use Protobuf,
    full_name: "livekit.CreateSIPDispatchRuleRequest",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :dispatch_rule, 10,
    type: Livekitex.Proto.Livekit.SIPDispatchRuleInfo,
    json_name: "dispatchRule"

  field :rule, 1, type: Livekitex.Proto.Livekit.SIPDispatchRule, deprecated: true
  field :trunk_ids, 2, repeated: true, type: :string, json_name: "trunkIds", deprecated: true
  field :hide_phone_number, 3, type: :bool, json_name: "hidePhoneNumber", deprecated: true

  field :inbound_numbers, 6,
    repeated: true,
    type: :string,
    json_name: "inboundNumbers",
    deprecated: true

  field :name, 4, type: :string, deprecated: true
  field :metadata, 5, type: :string, deprecated: true

  field :attributes, 7,
    repeated: true,
    type: Livekitex.Proto.Livekit.CreateSIPDispatchRuleRequest.AttributesEntry,
    map: true,
    deprecated: true

  field :room_preset, 8, type: :string, json_name: "roomPreset", deprecated: true

  field :room_config, 9,
    type: Livekitex.Proto.Livekit.RoomConfiguration,
    json_name: "roomConfig",
    deprecated: true
end

defmodule Livekitex.Proto.Livekit.UpdateSIPDispatchRuleRequest do
  use Protobuf,
    full_name: "livekit.UpdateSIPDispatchRuleRequest",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  oneof :action, 0

  field :sip_dispatch_rule_id, 1, type: :string, json_name: "sipDispatchRuleId", deprecated: false
  field :replace, 2, type: Livekitex.Proto.Livekit.SIPDispatchRuleInfo, oneof: 0
  field :update, 3, type: Livekitex.Proto.Livekit.SIPDispatchRuleUpdate, oneof: 0
end

defmodule Livekitex.Proto.Livekit.SIPDispatchRuleInfo.AttributesEntry do
  use Protobuf,
    full_name: "livekit.SIPDispatchRuleInfo.AttributesEntry",
    map: true,
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :key, 1, type: :string
  field :value, 2, type: :string
end

defmodule Livekitex.Proto.Livekit.SIPDispatchRuleInfo do
  use Protobuf,
    full_name: "livekit.SIPDispatchRuleInfo",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :sip_dispatch_rule_id, 1, type: :string, json_name: "sipDispatchRuleId", deprecated: false
  field :rule, 2, type: Livekitex.Proto.Livekit.SIPDispatchRule
  field :trunk_ids, 3, repeated: true, type: :string, json_name: "trunkIds"
  field :hide_phone_number, 4, type: :bool, json_name: "hidePhoneNumber"
  field :inbound_numbers, 7, repeated: true, type: :string, json_name: "inboundNumbers"
  field :numbers, 13, repeated: true, type: :string
  field :name, 5, type: :string
  field :metadata, 6, type: :string, deprecated: false

  field :attributes, 8,
    repeated: true,
    type: Livekitex.Proto.Livekit.SIPDispatchRuleInfo.AttributesEntry,
    map: true,
    deprecated: false

  field :room_preset, 9, type: :string, json_name: "roomPreset"
  field :room_config, 10, type: Livekitex.Proto.Livekit.RoomConfiguration, json_name: "roomConfig"
  field :media, 16, type: Livekitex.Proto.Livekit.SIPMediaConfig
  field :krisp_enabled, 11, type: :bool, json_name: "krispEnabled"

  field :media_encryption, 12,
    type: Livekitex.Proto.Livekit.SIPMediaEncryption,
    json_name: "mediaEncryption",
    enum: true,
    deprecated: true

  field :created_at, 14, type: Google.Protobuf.Timestamp, json_name: "createdAt"
  field :updated_at, 15, type: Google.Protobuf.Timestamp, json_name: "updatedAt"
end

defmodule Livekitex.Proto.Livekit.SIPDispatchRuleUpdate.AttributesEntry do
  use Protobuf,
    full_name: "livekit.SIPDispatchRuleUpdate.AttributesEntry",
    map: true,
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :key, 1, type: :string
  field :value, 2, type: :string
end

defmodule Livekitex.Proto.Livekit.SIPDispatchRuleUpdate do
  use Protobuf,
    full_name: "livekit.SIPDispatchRuleUpdate",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :trunk_ids, 1, type: Livekitex.Proto.Livekit.ListUpdate, json_name: "trunkIds"
  field :rule, 2, type: Livekitex.Proto.Livekit.SIPDispatchRule
  field :name, 3, proto3_optional: true, type: :string
  field :metadata, 4, proto3_optional: true, type: :string, deprecated: false

  field :attributes, 5,
    repeated: true,
    type: Livekitex.Proto.Livekit.SIPDispatchRuleUpdate.AttributesEntry,
    map: true,
    deprecated: false

  field :media_encryption, 6,
    proto3_optional: true,
    type: Livekitex.Proto.Livekit.SIPMediaEncryption,
    json_name: "mediaEncryption",
    enum: true,
    deprecated: true

  field :media, 7, type: Livekitex.Proto.Livekit.SIPMediaConfig
end

defmodule Livekitex.Proto.Livekit.ListSIPDispatchRuleRequest do
  @moduledoc """
  ListSIPDispatchRuleRequest lists dispatch rules for given filters. If no filters are set, all rules are listed.
  """

  use Protobuf,
    full_name: "livekit.ListSIPDispatchRuleRequest",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :page, 3, type: Livekitex.Proto.Livekit.Pagination
  field :dispatch_rule_ids, 1, repeated: true, type: :string, json_name: "dispatchRuleIds"
  field :trunk_ids, 2, repeated: true, type: :string, json_name: "trunkIds"
end

defmodule Livekitex.Proto.Livekit.ListSIPDispatchRuleResponse do
  use Protobuf,
    full_name: "livekit.ListSIPDispatchRuleResponse",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :items, 1, repeated: true, type: Livekitex.Proto.Livekit.SIPDispatchRuleInfo
end

defmodule Livekitex.Proto.Livekit.DeleteSIPDispatchRuleRequest do
  use Protobuf,
    full_name: "livekit.DeleteSIPDispatchRuleRequest",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :sip_dispatch_rule_id, 1, type: :string, json_name: "sipDispatchRuleId", deprecated: false
end

defmodule Livekitex.Proto.Livekit.SIPOutboundConfig.HeadersToAttributesEntry do
  use Protobuf,
    full_name: "livekit.SIPOutboundConfig.HeadersToAttributesEntry",
    map: true,
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :key, 1, type: :string
  field :value, 2, type: :string
end

defmodule Livekitex.Proto.Livekit.SIPOutboundConfig.AttributesToHeadersEntry do
  use Protobuf,
    full_name: "livekit.SIPOutboundConfig.AttributesToHeadersEntry",
    map: true,
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :key, 1, type: :string
  field :value, 2, type: :string
end

defmodule Livekitex.Proto.Livekit.SIPOutboundConfig do
  use Protobuf,
    full_name: "livekit.SIPOutboundConfig",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :hostname, 1, type: :string
  field :destination_country, 7, type: :string, json_name: "destinationCountry"
  field :transport, 2, type: Livekitex.Proto.Livekit.SIPTransport, enum: true
  field :auth_username, 3, type: :string, json_name: "authUsername", deprecated: false
  field :auth_password, 4, type: :string, json_name: "authPassword", deprecated: false

  field :headers_to_attributes, 5,
    repeated: true,
    type: Livekitex.Proto.Livekit.SIPOutboundConfig.HeadersToAttributesEntry,
    json_name: "headersToAttributes",
    map: true

  field :attributes_to_headers, 6,
    repeated: true,
    type: Livekitex.Proto.Livekit.SIPOutboundConfig.AttributesToHeadersEntry,
    json_name: "attributesToHeaders",
    map: true

  field :from_host, 8, type: :string, json_name: "fromHost"
end

defmodule Livekitex.Proto.Livekit.CreateSIPParticipantRequest.ParticipantAttributesEntry do
  use Protobuf,
    full_name: "livekit.CreateSIPParticipantRequest.ParticipantAttributesEntry",
    map: true,
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :key, 1, type: :string
  field :value, 2, type: :string
end

defmodule Livekitex.Proto.Livekit.CreateSIPParticipantRequest.HeadersEntry do
  use Protobuf,
    full_name: "livekit.CreateSIPParticipantRequest.HeadersEntry",
    map: true,
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :key, 1, type: :string
  field :value, 2, type: :string
end

defmodule Livekitex.Proto.Livekit.CreateSIPParticipantRequest do
  @moduledoc """
  A SIP Participant is a singular SIP session connected to a LiveKit room via
  a SIP Trunk into a SIP DispatchRule
  """

  use Protobuf,
    full_name: "livekit.CreateSIPParticipantRequest",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :sip_trunk_id, 1, type: :string, json_name: "sipTrunkId", deprecated: false
  field :trunk, 20, type: Livekitex.Proto.Livekit.SIPOutboundConfig

  field :sip_request_uri, 24,
    type: Livekitex.Proto.Livekit.SIPRequestDest,
    json_name: "sipRequestUri"

  field :sip_to_header, 25, type: Livekitex.Proto.Livekit.SIPNamedDest, json_name: "sipToHeader"

  field :sip_from_header, 26,
    type: Livekitex.Proto.Livekit.SIPNamedDest,
    json_name: "sipFromHeader"

  field :sip_call_to, 2, type: :string, json_name: "sipCallTo"
  field :to_user_override, 27, type: :string, json_name: "toUserOverride"
  field :sip_number, 15, type: :string, json_name: "sipNumber"
  field :room_name, 3, type: :string, json_name: "roomName"
  field :participant_identity, 4, type: :string, json_name: "participantIdentity"
  field :participant_name, 7, type: :string, json_name: "participantName", deprecated: false

  field :participant_metadata, 8,
    type: :string,
    json_name: "participantMetadata",
    deprecated: false

  field :participant_attributes, 9,
    repeated: true,
    type: Livekitex.Proto.Livekit.CreateSIPParticipantRequest.ParticipantAttributesEntry,
    json_name: "participantAttributes",
    map: true,
    deprecated: false

  field :dtmf, 5, type: :string
  field :play_ringtone, 6, type: :bool, json_name: "playRingtone", deprecated: true
  field :play_dialtone, 13, type: :bool, json_name: "playDialtone", deprecated: true
  field :dialtone, 28, type: Livekitex.Proto.Livekit.SIPDialtone, enum: true
  field :hide_phone_number, 10, type: :bool, json_name: "hidePhoneNumber"

  field :headers, 16,
    repeated: true,
    type: Livekitex.Proto.Livekit.CreateSIPParticipantRequest.HeadersEntry,
    map: true,
    deprecated: false

  field :include_headers, 17,
    type: Livekitex.Proto.Livekit.SIPHeaderOptions,
    json_name: "includeHeaders",
    enum: true

  field :ringing_timeout, 11, type: Google.Protobuf.Duration, json_name: "ringingTimeout"
  field :max_call_duration, 12, type: Google.Protobuf.Duration, json_name: "maxCallDuration"
  field :krisp_enabled, 14, type: :bool, json_name: "krispEnabled"

  field :media_encryption, 18,
    type: Livekitex.Proto.Livekit.SIPMediaEncryption,
    json_name: "mediaEncryption",
    enum: true,
    deprecated: true

  field :media, 23, type: Livekitex.Proto.Livekit.SIPMediaConfig
  field :wait_until_answered, 19, type: :bool, json_name: "waitUntilAnswered"

  field :display_name, 21,
    proto3_optional: true,
    type: :string,
    json_name: "displayName",
    deprecated: false

  field :destination, 22, proto3_optional: true, type: Livekitex.Proto.Livekit.Destination
  field :sip_source_call_id, 29, type: :string, json_name: "sipSourceCallId", deprecated: false
end

defmodule Livekitex.Proto.Livekit.SIPParticipantInfo do
  use Protobuf,
    full_name: "livekit.SIPParticipantInfo",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :participant_id, 1, type: :string, json_name: "participantId", deprecated: false
  field :participant_identity, 2, type: :string, json_name: "participantIdentity"
  field :room_name, 3, type: :string, json_name: "roomName"
  field :sip_call_id, 4, type: :string, json_name: "sipCallId", deprecated: false
end

defmodule Livekitex.Proto.Livekit.TransferSIPParticipantRequest.HeadersEntry do
  use Protobuf,
    full_name: "livekit.TransferSIPParticipantRequest.HeadersEntry",
    map: true,
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :key, 1, type: :string
  field :value, 2, type: :string
end

defmodule Livekitex.Proto.Livekit.TransferSIPParticipantRequest do
  use Protobuf,
    full_name: "livekit.TransferSIPParticipantRequest",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :participant_identity, 1, type: :string, json_name: "participantIdentity"
  field :room_name, 2, type: :string, json_name: "roomName"
  field :transfer_to, 3, type: :string, json_name: "transferTo"
  field :play_dialtone, 4, type: :bool, json_name: "playDialtone", deprecated: true
  field :dialtone, 7, type: Livekitex.Proto.Livekit.SIPDialtone, enum: true

  field :headers, 5,
    repeated: true,
    type: Livekitex.Proto.Livekit.TransferSIPParticipantRequest.HeadersEntry,
    map: true,
    deprecated: false

  field :ringing_timeout, 6, type: Google.Protobuf.Duration, json_name: "ringingTimeout"
end

defmodule Livekitex.Proto.Livekit.TransferSIPParticipantResponse do
  @moduledoc """
  Added in https://github.com/livekit/protocol/pull/1730. Not needed after all:
  will be rolled back to an empty message once STR_CALL_ENDED is reported as an
  error like every other failed transfer.
  """

  use Protobuf,
    full_name: "livekit.TransferSIPParticipantResponse",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :transfer_id, 1, type: :string, json_name: "transferId", deprecated: false
  field :status, 2, type: Livekitex.Proto.Livekit.SIPTransferStatus, enum: true
  field :reason, 3, type: Livekitex.Proto.Livekit.SIPTransferReason, enum: true
  field :sip_status, 4, type: Livekitex.Proto.Livekit.SIPStatus, json_name: "sipStatus"
end

defmodule Livekitex.Proto.Livekit.SIPTransferError do
  @moduledoc """
  Details of a failed SIP transfer, attached to the error.
  """

  use Protobuf,
    full_name: "livekit.SIPTransferError",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :transfer_id, 1, type: :string, json_name: "transferId", deprecated: false
  field :reason, 2, type: Livekitex.Proto.Livekit.SIPTransferReason, enum: true
  field :sip_status, 3, type: Livekitex.Proto.Livekit.SIPStatus, json_name: "sipStatus"
end

defmodule Livekitex.Proto.Livekit.SIPCallInfo.ParticipantAttributesEntry do
  use Protobuf,
    full_name: "livekit.SIPCallInfo.ParticipantAttributesEntry",
    map: true,
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :key, 1, type: :string
  field :value, 2, type: :string
end

defmodule Livekitex.Proto.Livekit.SIPCallInfo do
  use Protobuf,
    full_name: "livekit.SIPCallInfo",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :call_id, 1, type: :string, json_name: "callId", deprecated: false
  field :trunk_id, 2, type: :string, json_name: "trunkId", deprecated: false
  field :dispatch_rule_id, 16, type: :string, json_name: "dispatchRuleId", deprecated: false
  field :region, 17, type: :string
  field :room_name, 3, type: :string, json_name: "roomName"
  field :room_id, 4, type: :string, json_name: "roomId", deprecated: false
  field :participant_identity, 5, type: :string, json_name: "participantIdentity"

  field :participant_attributes, 18,
    repeated: true,
    type: Livekitex.Proto.Livekit.SIPCallInfo.ParticipantAttributesEntry,
    json_name: "participantAttributes",
    map: true,
    deprecated: false

  field :from_uri, 6, type: Livekitex.Proto.Livekit.SIPUri, json_name: "fromUri"
  field :to_uri, 7, type: Livekitex.Proto.Livekit.SIPUri, json_name: "toUri"
  field :created_at, 9, type: :int64, json_name: "createdAt", deprecated: true
  field :started_at, 10, type: :int64, json_name: "startedAt", deprecated: true
  field :ended_at, 11, type: :int64, json_name: "endedAt", deprecated: true

  field :enabled_features, 14,
    repeated: true,
    type: Livekitex.Proto.Livekit.SIPFeature,
    json_name: "enabledFeatures",
    enum: true

  field :call_direction, 15,
    type: Livekitex.Proto.Livekit.SIPCallDirection,
    json_name: "callDirection",
    enum: true

  field :call_status, 8,
    type: Livekitex.Proto.Livekit.SIPCallStatus,
    json_name: "callStatus",
    enum: true

  field :created_at_ns, 22, type: :int64, json_name: "createdAtNs"
  field :started_at_ns, 23, type: :int64, json_name: "startedAtNs"
  field :ended_at_ns, 24, type: :int64, json_name: "endedAtNs"

  field :disconnect_reason, 12,
    type: Livekitex.Proto.Livekit.DisconnectReason,
    json_name: "disconnectReason",
    enum: true

  field :error, 13, type: :string

  field :call_status_code, 19,
    type: Livekitex.Proto.Livekit.SIPStatus,
    json_name: "callStatusCode"

  field :audio_codec, 20, type: :string, json_name: "audioCodec"
  field :media_encryption, 21, type: :string, json_name: "mediaEncryption"
  field :pcap_file_link, 25, type: :string, json_name: "pcapFileLink"
  field :call_context, 26, repeated: true, type: Google.Protobuf.Any, json_name: "callContext"
  field :provider_info, 27, type: Livekitex.Proto.Livekit.ProviderInfo, json_name: "providerInfo"
  field :sip_call_id, 28, type: :string, json_name: "sipCallId", deprecated: false
end

defmodule Livekitex.Proto.Livekit.SIPTransferInfo do
  use Protobuf,
    full_name: "livekit.SIPTransferInfo",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :transfer_id, 1, type: :string, json_name: "transferId", deprecated: false
  field :call_id, 2, type: :string, json_name: "callId", deprecated: false
  field :transfer_to, 3, type: :string, json_name: "transferTo"
  field :transfer_initiated_at_ns, 4, type: :int64, json_name: "transferInitiatedAtNs"
  field :transfer_completed_at_ns, 5, type: :int64, json_name: "transferCompletedAtNs"

  field :transfer_status, 6,
    type: Livekitex.Proto.Livekit.SIPTransferStatus,
    json_name: "transferStatus",
    enum: true

  field :error, 7, type: :string

  field :transfer_status_code, 8,
    type: Livekitex.Proto.Livekit.SIPStatus,
    json_name: "transferStatusCode"

  field :reason, 9, type: Livekitex.Proto.Livekit.SIPTransferReason, enum: true
end

defmodule Livekitex.Proto.Livekit.SIPUri do
  use Protobuf, full_name: "livekit.SIPUri", protoc_gen_elixir_version: "0.17.1", syntax: :proto3

  field :user, 1, type: :string
  field :host, 2, type: :string
  field :ip, 3, type: :string
  field :port, 4, type: :uint32
  field :transport, 5, type: Livekitex.Proto.Livekit.SIPTransport, enum: true
end

defmodule Livekitex.Proto.Livekit.SIPRequestDest do
  use Protobuf,
    full_name: "livekit.SIPRequestDest",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  oneof :uri, 0

  field :raw, 1, type: :string, oneof: 0
  field :values, 2, type: Livekitex.Proto.Livekit.SIPUri, oneof: 0
end

defmodule Livekitex.Proto.Livekit.SIPNamedDest do
  use Protobuf,
    full_name: "livekit.SIPNamedDest",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  oneof :uri, 0

  field :display_name, 3, type: :string, json_name: "displayName"
  field :raw, 1, type: :string, oneof: 0
  field :values, 2, type: Livekitex.Proto.Livekit.SIPUri, oneof: 0
end

defmodule Livekitex.Proto.Livekit.Destination do
  use Protobuf,
    full_name: "livekit.Destination",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :city, 1, type: :string
  field :country, 2, type: :string
  field :region, 3, type: :string
end

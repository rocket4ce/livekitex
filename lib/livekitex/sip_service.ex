defmodule Livekitex.SIPService do
  @moduledoc """
  SIP telephony (`livekit.SIP`): trunks, dispatch rules, outbound calls and transfers.

  Trunk and dispatch-rule management uses a token with `sip.admin`; dialing uses
  `sip.call` (transfers also need `roomAdmin` for the room).

  ## Outbound call

      {:ok, trunk} =
        Livekitex.SIPService.create_outbound_trunk(client,
          name: "Twilio",
          address: "my-trunk.pstn.twilio.com",
          numbers: ["+15105550100"],
          auth_username: "user",
          auth_password: "pass"
        )

      {:ok, participant} =
        Livekitex.SIPService.create_sip_participant(client, trunk.sip_trunk_id,
          "+15105550123", "support-call",
          participant_identity: "caller",
          wait_until_answered: true,
          ringing_timeout: 30
        )

  On dialing failures, `Livekitex.Error.sip_status/1` returns the SIP status, e.g.
  `{486, "Busy Here"}`.

  ## Inbound calls

      {:ok, trunk} = Livekitex.SIPService.create_inbound_trunk(client, name: "Inbound", numbers: ["+15105550100"])

      {:ok, rule} =
        Livekitex.SIPService.create_dispatch_rule(client,
          [dispatch_rule_individual: [room_prefix: "call-"]],
          trunk_ids: [trunk.sip_trunk_id],
          room_config: [agents: [[agent_name: "phone-agent"]]]
        )

  `google.protobuf.Duration` fields (`ringing_timeout`, `max_call_duration`) accept an
  integer number of seconds.
  """

  import Livekitex.Service

  alias Livekitex.Client

  alias Livekitex.Proto.Livekit.{
    CreateSIPDispatchRuleRequest,
    CreateSIPInboundTrunkRequest,
    CreateSIPOutboundTrunkRequest,
    CreateSIPParticipantRequest,
    DeleteSIPDispatchRuleRequest,
    DeleteSIPTrunkRequest,
    GetSIPInboundTrunkRequest,
    GetSIPInboundTrunkResponse,
    GetSIPOutboundTrunkRequest,
    GetSIPOutboundTrunkResponse,
    ListSIPDispatchRuleRequest,
    ListSIPDispatchRuleResponse,
    ListSIPInboundTrunkRequest,
    ListSIPInboundTrunkResponse,
    ListSIPOutboundTrunkRequest,
    ListSIPOutboundTrunkResponse,
    SIPDispatchRuleInfo,
    SIPInboundTrunkInfo,
    SIPOutboundTrunkInfo,
    SIPParticipantInfo,
    SIPTrunkInfo,
    TransferSIPParticipantRequest,
    TransferSIPParticipantResponse,
    UpdateSIPDispatchRuleRequest,
    UpdateSIPInboundTrunkRequest,
    UpdateSIPOutboundTrunkRequest
  }

  @service "SIP"
  @admin [sip: [admin: true]]
  @default_ringing_timeout 30

  @type result(t) :: {:ok, t} | {:error, Livekitex.Error.t()}

  ## Inbound trunks

  @doc """
  Creates an inbound trunk. `trunk` is a `SIPInboundTrunkInfo` or its fields as a
  keyword list (`:name`, `:numbers`, `:allowed_addresses`, `:allowed_numbers`,
  `:auth_username`, `:auth_password`, `:krisp_enabled`, ...).
  """
  @spec create_inbound_trunk(Client.t(), SIPInboundTrunkInfo.t() | keyword(), keyword()) ::
          result(SIPInboundTrunkInfo.t())
  def create_inbound_trunk(client, trunk, opts \\ []) do
    call_opts = call_opts!(opts)

    rpc(
      client,
      @service,
      "CreateSIPInboundTrunk",
      CreateSIPInboundTrunkRequest,
      [trunk: trunk],
      SIPInboundTrunkInfo,
      @admin,
      no_retry(call_opts)
    )
  end

  @doc """
  Partially updates an inbound trunk. `changes` are `SIPInboundTrunkUpdate` fields;
  list fields use `ListUpdate` (`[set: [...]]`, `[add: [...]]`, `[remove: [...]]`).

      update_inbound_trunk(client, "ST_...", name: "Main line", numbers: [add: ["+15105550101"]])
  """
  @spec update_inbound_trunk(Client.t(), String.t(), keyword(), keyword()) ::
          result(SIPInboundTrunkInfo.t())
  def update_inbound_trunk(client, trunk_id, changes, opts \\ []) do
    call_opts = call_opts!(opts)
    fields = [sip_trunk_id: trunk_id, update: changes]

    rpc(
      client,
      @service,
      "UpdateSIPInboundTrunk",
      UpdateSIPInboundTrunkRequest,
      fields,
      SIPInboundTrunkInfo,
      @admin,
      call_opts
    )
  end

  @doc "Replaces an inbound trunk with a new definition."
  @spec replace_inbound_trunk(
          Client.t(),
          String.t(),
          SIPInboundTrunkInfo.t() | keyword(),
          keyword()
        ) ::
          result(SIPInboundTrunkInfo.t())
  def replace_inbound_trunk(client, trunk_id, trunk, opts \\ []) do
    call_opts = call_opts!(opts)
    fields = [sip_trunk_id: trunk_id, replace: trunk]

    rpc(
      client,
      @service,
      "UpdateSIPInboundTrunk",
      UpdateSIPInboundTrunkRequest,
      fields,
      SIPInboundTrunkInfo,
      @admin,
      call_opts
    )
  end

  @doc "Gets an inbound trunk by id."
  @spec get_inbound_trunk(Client.t(), String.t(), keyword()) :: result(SIPInboundTrunkInfo.t())
  def get_inbound_trunk(client, trunk_id, opts \\ []) do
    call_opts = call_opts!(opts)

    client
    |> rpc(
      @service,
      "GetSIPInboundTrunk",
      GetSIPInboundTrunkRequest,
      [sip_trunk_id: trunk_id],
      GetSIPInboundTrunkResponse,
      @admin,
      call_opts
    )
    |> map_ok(& &1.trunk)
  end

  @doc "Lists inbound trunks, optionally filtered by `:trunk_ids` or `:numbers`."
  @spec list_inbound_trunks(Client.t(), keyword()) :: result([SIPInboundTrunkInfo.t()])
  def list_inbound_trunks(client, opts \\ []) do
    {call_opts, fields} = split_opts(opts)

    client
    |> rpc(
      @service,
      "ListSIPInboundTrunk",
      ListSIPInboundTrunkRequest,
      fields,
      ListSIPInboundTrunkResponse,
      @admin,
      call_opts
    )
    |> map_ok(& &1.items)
  end

  ## Outbound trunks

  @doc """
  Creates an outbound trunk. `trunk` is a `SIPOutboundTrunkInfo` or its fields
  (`:name`, `:address`, `:transport`, `:numbers`, `:auth_username`, `:auth_password`, ...).
  """
  @spec create_outbound_trunk(Client.t(), SIPOutboundTrunkInfo.t() | keyword(), keyword()) ::
          result(SIPOutboundTrunkInfo.t())
  def create_outbound_trunk(client, trunk, opts \\ []) do
    call_opts = call_opts!(opts)

    rpc(
      client,
      @service,
      "CreateSIPOutboundTrunk",
      CreateSIPOutboundTrunkRequest,
      [trunk: trunk],
      SIPOutboundTrunkInfo,
      @admin,
      no_retry(call_opts)
    )
  end

  @doc "Partially updates an outbound trunk with `SIPOutboundTrunkUpdate` fields."
  @spec update_outbound_trunk(Client.t(), String.t(), keyword(), keyword()) ::
          result(SIPOutboundTrunkInfo.t())
  def update_outbound_trunk(client, trunk_id, changes, opts \\ []) do
    call_opts = call_opts!(opts)
    fields = [sip_trunk_id: trunk_id, update: changes]

    rpc(
      client,
      @service,
      "UpdateSIPOutboundTrunk",
      UpdateSIPOutboundTrunkRequest,
      fields,
      SIPOutboundTrunkInfo,
      @admin,
      call_opts
    )
  end

  @doc "Replaces an outbound trunk with a new definition."
  @spec replace_outbound_trunk(
          Client.t(),
          String.t(),
          SIPOutboundTrunkInfo.t() | keyword(),
          keyword()
        ) ::
          result(SIPOutboundTrunkInfo.t())
  def replace_outbound_trunk(client, trunk_id, trunk, opts \\ []) do
    call_opts = call_opts!(opts)
    fields = [sip_trunk_id: trunk_id, replace: trunk]

    rpc(
      client,
      @service,
      "UpdateSIPOutboundTrunk",
      UpdateSIPOutboundTrunkRequest,
      fields,
      SIPOutboundTrunkInfo,
      @admin,
      call_opts
    )
  end

  @doc "Gets an outbound trunk by id."
  @spec get_outbound_trunk(Client.t(), String.t(), keyword()) :: result(SIPOutboundTrunkInfo.t())
  def get_outbound_trunk(client, trunk_id, opts \\ []) do
    call_opts = call_opts!(opts)

    client
    |> rpc(
      @service,
      "GetSIPOutboundTrunk",
      GetSIPOutboundTrunkRequest,
      [sip_trunk_id: trunk_id],
      GetSIPOutboundTrunkResponse,
      @admin,
      call_opts
    )
    |> map_ok(& &1.trunk)
  end

  @doc "Lists outbound trunks, optionally filtered by `:trunk_ids` or `:numbers`."
  @spec list_outbound_trunks(Client.t(), keyword()) :: result([SIPOutboundTrunkInfo.t()])
  def list_outbound_trunks(client, opts \\ []) do
    {call_opts, fields} = split_opts(opts)

    client
    |> rpc(
      @service,
      "ListSIPOutboundTrunk",
      ListSIPOutboundTrunkRequest,
      fields,
      ListSIPOutboundTrunkResponse,
      @admin,
      call_opts
    )
    |> map_ok(& &1.items)
  end

  @doc "Deletes an inbound or outbound trunk."
  @spec delete_trunk(Client.t(), String.t(), keyword()) :: result(SIPTrunkInfo.t())
  def delete_trunk(client, trunk_id, opts \\ []) do
    call_opts = call_opts!(opts)

    rpc(
      client,
      @service,
      "DeleteSIPTrunk",
      DeleteSIPTrunkRequest,
      [sip_trunk_id: trunk_id],
      SIPTrunkInfo,
      @admin,
      call_opts
    )
  end

  ## Dispatch rules

  @doc """
  Creates a dispatch rule.

  `rule` is a `SIPDispatchRule` (or its fields), e.g.
  `[dispatch_rule_individual: [room_prefix: "call-"]]`,
  `[dispatch_rule_direct: [room_name: "lobby"]]` or
  `[dispatch_rule_callee: [room_prefix: "number-"]]`.

  `opts` accepts the other `SIPDispatchRuleInfo` fields: `:name`, `:trunk_ids`,
  `:inbound_numbers`, `:hide_phone_number`, `:metadata`, `:attributes`,
  `:room_preset`, `:room_config`, `:krisp_enabled`, ...
  """
  @spec create_dispatch_rule(Client.t(), struct() | keyword(), keyword()) ::
          result(SIPDispatchRuleInfo.t())
  def create_dispatch_rule(client, rule, opts \\ []) do
    {call_opts, fields} = split_opts(opts)
    request = [dispatch_rule: Keyword.put(fields, :rule, rule)]

    rpc(
      client,
      @service,
      "CreateSIPDispatchRule",
      CreateSIPDispatchRuleRequest,
      request,
      SIPDispatchRuleInfo,
      @admin,
      no_retry(call_opts)
    )
  end

  @doc "Partially updates a dispatch rule with `SIPDispatchRuleUpdate` fields."
  @spec update_dispatch_rule(Client.t(), String.t(), keyword(), keyword()) ::
          result(SIPDispatchRuleInfo.t())
  def update_dispatch_rule(client, rule_id, changes, opts \\ []) do
    call_opts = call_opts!(opts)
    fields = [sip_dispatch_rule_id: rule_id, update: changes]

    rpc(
      client,
      @service,
      "UpdateSIPDispatchRule",
      UpdateSIPDispatchRuleRequest,
      fields,
      SIPDispatchRuleInfo,
      @admin,
      call_opts
    )
  end

  @doc "Replaces a dispatch rule with a new `SIPDispatchRuleInfo`."
  @spec replace_dispatch_rule(
          Client.t(),
          String.t(),
          SIPDispatchRuleInfo.t() | keyword(),
          keyword()
        ) ::
          result(SIPDispatchRuleInfo.t())
  def replace_dispatch_rule(client, rule_id, info, opts \\ []) do
    call_opts = call_opts!(opts)
    fields = [sip_dispatch_rule_id: rule_id, replace: info]

    rpc(
      client,
      @service,
      "UpdateSIPDispatchRule",
      UpdateSIPDispatchRuleRequest,
      fields,
      SIPDispatchRuleInfo,
      @admin,
      call_opts
    )
  end

  @doc "Lists dispatch rules, optionally filtered by `:dispatch_rule_ids` or `:trunk_ids`."
  @spec list_dispatch_rules(Client.t(), keyword()) :: result([SIPDispatchRuleInfo.t()])
  def list_dispatch_rules(client, opts \\ []) do
    {call_opts, fields} = split_opts(opts)

    client
    |> rpc(
      @service,
      "ListSIPDispatchRule",
      ListSIPDispatchRuleRequest,
      fields,
      ListSIPDispatchRuleResponse,
      @admin,
      call_opts
    )
    |> map_ok(& &1.items)
  end

  @doc """
  Gets a dispatch rule by id (LiveKit has no Get RPC; this filters `ListSIPDispatchRule`).
  Returns `{:ok, nil}` when not found.
  """
  @spec get_dispatch_rule(Client.t(), String.t(), keyword()) ::
          result(SIPDispatchRuleInfo.t() | nil)
  def get_dispatch_rule(client, rule_id, opts \\ []) do
    client
    |> list_dispatch_rules(Keyword.put(opts, :dispatch_rule_ids, [rule_id]))
    |> map_ok(&List.first/1)
  end

  @doc "Deletes a dispatch rule."
  @spec delete_dispatch_rule(Client.t(), String.t(), keyword()) :: result(SIPDispatchRuleInfo.t())
  def delete_dispatch_rule(client, rule_id, opts \\ []) do
    call_opts = call_opts!(opts)

    rpc(
      client,
      @service,
      "DeleteSIPDispatchRule",
      DeleteSIPDispatchRuleRequest,
      [sip_dispatch_rule_id: rule_id],
      SIPDispatchRuleInfo,
      @admin,
      call_opts
    )
  end

  ## Calls

  @doc """
  Dials a phone number through an outbound trunk and joins the callee to `room`.

  ## Options

  Any `CreateSIPParticipantRequest` field, notably `:participant_identity`,
  `:participant_name`, `:participant_metadata`, `:participant_attributes`, `:dtmf`,
  `:wait_until_answered`, `:ringing_timeout` (seconds), `:max_call_duration`
  (seconds), `:krisp_enabled`, `:hide_phone_number`, `:headers`, `:display_name`,
  `:sip_number`.

  With `wait_until_answered: true` the HTTP timeout is extended to cover the ringing
  time. Never retried automatically.
  """
  @spec create_sip_participant(Client.t(), String.t(), String.t(), String.t(), keyword()) ::
          result(SIPParticipantInfo.t())
  def create_sip_participant(client, trunk_id, number, room, opts \\ []) do
    {call_opts, fields} = split_opts(opts)
    fields = Keyword.merge(fields, sip_trunk_id: trunk_id, sip_call_to: number, room_name: room)
    call_opts = call_opts |> no_retry() |> dial_timeout(fields, @default_ringing_timeout)

    rpc(
      client,
      @service,
      "CreateSIPParticipant",
      CreateSIPParticipantRequest,
      fields,
      SIPParticipantInfo,
      [sip: [call: true]],
      call_opts
    )
  end

  @doc """
  Transfers a SIP participant to another number or SIP URI (`tel:+1...` or `sip:...`).

  `opts` accepts `:dialtone`, `:headers` and `:ringing_timeout` (seconds). Never retried
  automatically.
  """
  @spec transfer_sip_participant(Client.t(), String.t(), String.t(), String.t(), keyword()) ::
          :ok | {:error, Livekitex.Error.t()}
  def transfer_sip_participant(client, room, identity, transfer_to, opts \\ []) do
    {call_opts, fields} = split_opts(opts)

    fields =
      Keyword.merge(fields,
        room_name: room,
        participant_identity: identity,
        transfer_to: transfer_to
      )

    call_opts =
      call_opts
      |> no_retry()
      |> dial_timeout(Keyword.put(fields, :wait_until_answered, true), @default_ringing_timeout)

    grants = [sip: [call: true], video: [room_admin: true, room: room]]

    client
    |> rpc(
      @service,
      "TransferSIPParticipant",
      TransferSIPParticipantRequest,
      fields,
      TransferSIPParticipantResponse,
      grants,
      call_opts
    )
    |> to_ok()
  end
end

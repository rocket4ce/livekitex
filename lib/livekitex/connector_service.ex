defmodule Livekitex.ConnectorService do
  @moduledoc """
  WhatsApp and Twilio connectors (`livekit.Connector`).

  > #### Experimental · LiveKit Cloud only {: .warning}
  >
  > The Connector API is in beta on LiveKit Cloud and may change. These functions are
  > thin wrappers over the protocol messages in `Livekitex.Proto.Livekit`.

  ## Twilio Media Streams

      {:ok, %{connect_url: url}} =
        Livekitex.ConnectorService.connect_twilio_call(client, :TWILIO_CALL_DIRECTION_INBOUND,
          "support-call",
          agents: [[agent_name: "phone-agent"]],
          participant_identity: "caller"
        )

      # Return TwiML that streams the call to `url`.

  ## WhatsApp

      {:ok, %{whatsapp_call_id: call_id}} =
        Livekitex.ConnectorService.dial_whatsapp_call(client,
          whatsapp_phone_number_id: "...",
          whatsapp_to_phone_number: "+15105550123",
          whatsapp_api_key: "...",
          room_name: "wa-call",
          agents: [[agent_name: "whatsapp-agent"]]
        )

  Dial, accept and connect calls are never retried automatically. With
  `wait_until_answered: true` the HTTP timeout is extended to cover the ringing time.
  """

  import Livekitex.Service

  alias Livekitex.Client

  alias Livekitex.Proto.Livekit.{
    AcceptWhatsAppCallRequest,
    AcceptWhatsAppCallResponse,
    ConnectTwilioCallRequest,
    ConnectTwilioCallResponse,
    ConnectWhatsAppCallRequest,
    ConnectWhatsAppCallResponse,
    DialWhatsAppCallRequest,
    DialWhatsAppCallResponse,
    DisconnectWhatsAppCallRequest,
    DisconnectWhatsAppCallResponse
  }

  @service "Connector"

  @type result(t) :: {:ok, t} | {:error, Livekitex.Error.t()}

  @doc """
  Starts an outbound WhatsApp call. `request` is a `DialWhatsAppCallRequest` or its
  fields (`:room_name` is required).
  """
  @spec dial_whatsapp_call(Client.t(), struct() | keyword(), keyword()) ::
          result(DialWhatsAppCallResponse.t())
  def dial_whatsapp_call(client, request, opts \\ []) do
    {call_opts, fields} = split_opts(opts)
    request = merge_fields(request, fields)
    room = room_name!(request)

    rpc(
      client,
      @service,
      "DialWhatsAppCall",
      DialWhatsAppCallRequest,
      request,
      DialWhatsAppCallResponse,
      room_grant(room),
      no_retry(call_opts)
    )
  end

  @doc """
  Disconnects a WhatsApp call. `reason` is `:BUSINESS_INITIATED` (default) or `:USER_INITIATED`.
  """
  @spec disconnect_whatsapp_call(Client.t(), String.t(), String.t(), keyword()) ::
          :ok | {:error, Livekitex.Error.t()}
  def disconnect_whatsapp_call(client, whatsapp_call_id, whatsapp_api_key, opts \\ []) do
    {call_opts, fields} = split_opts(opts)

    fields =
      fields
      |> Keyword.put_new(:disconnect_reason, :BUSINESS_INITIATED)
      |> Keyword.merge(whatsapp_call_id: whatsapp_call_id, whatsapp_api_key: whatsapp_api_key)

    client
    |> rpc(
      @service,
      "DisconnectWhatsAppCall",
      DisconnectWhatsAppCallRequest,
      fields,
      DisconnectWhatsAppCallResponse,
      [video: [room_create: true]],
      call_opts
    )
    |> to_ok()
  end

  @doc """
  Connects an established WhatsApp call by sending the SDP answer
  (`sdp: [type: "answer", sdp: "..."]`).
  """
  @spec connect_whatsapp_call(Client.t(), String.t(), keyword(), keyword()) ::
          :ok | {:error, Livekitex.Error.t()}
  def connect_whatsapp_call(client, whatsapp_call_id, sdp, opts \\ []) do
    {call_opts, fields} = split_opts(opts)
    fields = Keyword.merge(fields, whatsapp_call_id: whatsapp_call_id, sdp: sdp)

    client
    |> rpc(
      @service,
      "ConnectWhatsAppCall",
      ConnectWhatsAppCallRequest,
      fields,
      ConnectWhatsAppCallResponse,
      [video: [room_create: true]],
      call_opts |> no_retry() |> dial_timeout(fields)
    )
    |> to_ok()
  end

  @doc """
  Accepts an inbound WhatsApp call. `request` is an `AcceptWhatsAppCallRequest` or its
  fields (`:room_name` is required). Returns the response with the room name.
  """
  @spec accept_whatsapp_call(Client.t(), struct() | keyword(), keyword()) ::
          result(AcceptWhatsAppCallResponse.t())
  def accept_whatsapp_call(client, request, opts \\ []) do
    {call_opts, fields} = split_opts(opts)
    request = merge_fields(request, fields)
    room = room_name!(request)

    rpc(
      client,
      @service,
      "AcceptWhatsAppCall",
      AcceptWhatsAppCallRequest,
      request,
      AcceptWhatsAppCallResponse,
      room_grant(room),
      call_opts |> no_retry() |> dial_timeout(request)
    )
  end

  @doc """
  Connects a Twilio call to a room. `direction` is `:TWILIO_CALL_DIRECTION_INBOUND` or
  `:TWILIO_CALL_DIRECTION_OUTBOUND`. Returns the response with the `connect_url` (a
  WebSocket URL for Twilio Media Streams).
  """
  @spec connect_twilio_call(Client.t(), atom(), String.t(), keyword()) ::
          result(ConnectTwilioCallResponse.t())
  def connect_twilio_call(client, direction, room, opts \\ []) do
    {call_opts, fields} = split_opts(opts)
    fields = Keyword.merge(fields, twilio_call_direction: direction, room_name: room)

    rpc(
      client,
      @service,
      "ConnectTwilioCall",
      ConnectTwilioCallRequest,
      fields,
      ConnectTwilioCallResponse,
      room_grant(room),
      no_retry(call_opts)
    )
  end

  defp room_grant(room), do: [video: [room_create: true, room: room]]

  defp room_name!(%{room_name: room}) when is_binary(room) and room != "", do: room

  defp room_name!(fields) when is_list(fields) do
    case fields[:room_name] do
      room when is_binary(room) and room != "" -> room
      _ -> raise ArgumentError, ":room_name is required"
    end
  end

  defp room_name!(_), do: raise(ArgumentError, ":room_name is required")
end

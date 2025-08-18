defmodule Livekitex.SIPServiceClient do
  @moduledoc """
  Low-level Twirp JSON client for LiveKit SIPService endpoints.

  This client uses JSON-encoded requests/responses to avoid requiring
  generated protobuf modules for SIP. It mirrors the paths in livekit.SIP.
  """

  @type token :: String.t()
  @type client :: Tesla.Client.t()

  # Trunks
  def create_inbound_trunk(client, token, req),
    do: post_json(client, token, "/twirp/livekit.SIP/CreateSIPInboundTrunk", %{trunk: req})

  def update_inbound_trunk(client, token, trunk_id, action),
    do:
      post_json(client, token, "/twirp/livekit.SIP/UpdateSIPInboundTrunk", %{
        sip_trunk_id: trunk_id,
        action: action
      })

  def get_inbound_trunk(client, token, trunk_id),
    do:
      post_json(client, token, "/twirp/livekit.SIP/GetSIPInboundTrunk", %{
        sip_trunk_id: trunk_id
      })

  def list_inbound_trunks(client, token, opts \\ %{}),
    do:
      post_json(client, token, "/twirp/livekit.SIP/ListSIPInboundTrunk", %{
        trunk_ids: Map.get(opts, :trunk_ids, Map.get(opts, "trunk_ids", [])),
        numbers: Map.get(opts, :numbers, Map.get(opts, "numbers", [])),
        page: Map.get(opts, :page, Map.get(opts, "page", %{}))
      })

  def create_outbound_trunk(client, token, req),
    do: post_json(client, token, "/twirp/livekit.SIP/CreateSIPOutboundTrunk", %{trunk: req})

  def update_outbound_trunk(client, token, trunk_id, action),
    do:
      post_json(client, token, "/twirp/livekit.SIP/UpdateSIPOutboundTrunk", %{
        sip_trunk_id: trunk_id,
        action: action
      })

  def get_outbound_trunk(client, token, trunk_id),
    do:
      post_json(client, token, "/twirp/livekit.SIP/GetSIPOutboundTrunk", %{
        sip_trunk_id: trunk_id
      })

  def list_outbound_trunks(client, token, opts \\ %{}),
    do:
      post_json(client, token, "/twirp/livekit.SIP/ListSIPOutboundTrunk", %{
        trunk_ids: Map.get(opts, :trunk_ids, Map.get(opts, "trunk_ids", [])),
        numbers: Map.get(opts, :numbers, Map.get(opts, "numbers", [])),
        page: Map.get(opts, :page, Map.get(opts, "page", %{}))
      })

  def delete_trunk(client, token, trunk_id),
    do:
      post_json(client, token, "/twirp/livekit.SIP/DeleteSIPTrunk", %{
        sip_trunk_id: trunk_id
      })

  # Dispatch rules
  def create_dispatch_rule(client, token, req),
    do:
      post_json(client, token, "/twirp/livekit.SIP/CreateSIPDispatchRule", %{dispatch_rule: req})

  def update_dispatch_rule(client, token, rule_id, action),
    do:
      post_json(client, token, "/twirp/livekit.SIP/UpdateSIPDispatchRule", %{
        sip_dispatch_rule_id: rule_id,
        action: action
      })

  def list_dispatch_rules(client, token, opts \\ %{}),
    do:
      post_json(client, token, "/twirp/livekit.SIP/ListSIPDispatchRule", %{
        dispatch_rule_ids:
          Map.get(opts, :dispatch_rule_ids, Map.get(opts, "dispatch_rule_ids", [])),
        trunk_ids: Map.get(opts, :trunk_ids, Map.get(opts, "trunk_ids", [])),
        page: Map.get(opts, :page, Map.get(opts, "page", %{}))
      })

  def delete_dispatch_rule(client, token, rule_id),
    do:
      post_json(client, token, "/twirp/livekit.SIP/DeleteSIPDispatchRule", %{
        sip_dispatch_rule_id: rule_id
      })

  # Participants
  def create_participant(client, token, req),
    do: post_json(client, token, "/twirp/livekit.SIP/CreateSIPParticipant", req)

  def transfer_participant(client, token, req),
    do: post_json(client, token, "/twirp/livekit.SIP/TransferSIPParticipant", req)

  # --- Internal helpers ---
  defp post_json(client, token, path, payload) do
    headers = [
      {"authorization", "Bearer #{token}"},
      {"content-type", "application/json"}
    ]

    body = Jason.encode!(payload)

    case Tesla.post(client, path, body, headers: headers) do
      {:ok, %Tesla.Env{status: 200, body: resp_body}} ->
        case Jason.decode(resp_body) do
          {:ok, decoded} -> {:ok, decoded}
          _ -> {:ok, resp_body}
        end

      {:ok, %Tesla.Env{body: error_body}} ->
        {:error, parse_twirp_error(error_body)}

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp parse_twirp_error(error_body) when is_binary(error_body) do
    case Jason.decode(error_body) do
      {:ok, %{"code" => code, "msg" => msg}} ->
        %{code: safe_atom(code), msg: msg}

      {:ok, %{"msg" => msg}} ->
        %{code: :internal, msg: msg}

      _ ->
        %{code: :internal, msg: "Unknown error"}
    end
  end

  defp parse_twirp_error(%{"code" => code, "msg" => msg}), do: %{code: safe_atom(code), msg: msg}

  defp parse_twirp_error(%{code: code, msg: msg}) when is_binary(code),
    do: %{code: safe_atom(code), msg: msg}

  defp parse_twirp_error(%{code: code, msg: msg}), do: %{code: code, msg: msg}
  defp parse_twirp_error(_), do: %{code: :internal, msg: "Unknown error"}

  defp safe_atom(code) when is_binary(code) do
    String.to_atom(code)
  rescue
    _ -> :internal
  end
end

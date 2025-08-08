defmodule Livekitex.EgressServiceClient do
  @moduledoc """
  Twirp client for LiveKit EgressService operations.
  """

  alias Livekit.{EgressInfo, ListEgressResponse}

  def start_room_composite_egress(client, request, token) do
    make_request(
      client,
      request,
      token,
      "/twirp/livekit.EgressService/StartRoomCompositeEgress",
      EgressInfo
    )
  end

  def start_track_composite_egress(client, request, token) do
    make_request(
      client,
      request,
      token,
      "/twirp/livekit.EgressService/StartTrackCompositeEgress",
      EgressInfo
    )
  end

  def start_track_egress(client, request, token) do
    make_request(
      client,
      request,
      token,
      "/twirp/livekit.EgressService/StartTrackEgress",
      EgressInfo
    )
  end

  def start_web_egress(client, request, token) do
    make_request(
      client,
      request,
      token,
      "/twirp/livekit.EgressService/StartWebEgress",
      EgressInfo
    )
  end

  def start_participant_egress(client, request, token) do
    make_request(
      client,
      request,
      token,
      "/twirp/livekit.EgressService/StartParticipantEgress",
      EgressInfo
    )
  end

  def update_layout(client, request, token) do
    make_request(client, request, token, "/twirp/livekit.EgressService/UpdateLayout", EgressInfo)
  end

  def update_stream(client, request, token) do
    make_request(client, request, token, "/twirp/livekit.EgressService/UpdateStream", EgressInfo)
  end

  def list_egress(client, request, token) do
    make_request(
      client,
      request,
      token,
      "/twirp/livekit.EgressService/ListEgress",
      ListEgressResponse
    )
  end

  def stop_egress(client, request, token) do
    make_request(client, request, token, "/twirp/livekit.EgressService/StopEgress", EgressInfo)
  end

  defp make_request(client, request, token, path, response_type) do
    headers = [{"authorization", "Bearer #{token}"}]
    body = Protobuf.encode(request)

    case Tesla.post(client, path, body, headers: headers) do
      {:ok, %Tesla.Env{status: 200, body: response_body}} ->
        {:ok, Protobuf.decode(response_body, response_type)}

      {:ok, %Tesla.Env{body: error_body}} ->
        {:error, parse_twirp_error(error_body)}

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp parse_twirp_error(error_body) do
    case Jason.decode(error_body) do
      {:ok, %{"code" => code, "msg" => msg}} ->
        %{code: String.to_atom(code), msg: msg}

      _ ->
        :unknown_twirp_error
    end
  end
end

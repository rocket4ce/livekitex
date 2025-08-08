defmodule Livekitex.RoomServiceClient do
  @moduledoc """
  Twirp client for LiveKit RoomService operations.
  """

  def create_room(client, request, token) do
    make_request(client, request, token, "/twirp/livekit.RoomService/CreateRoom")
  end

  def list_rooms(client, request, token) do
    make_request(client, request, token, "/twirp/livekit.RoomService/ListRooms")
  end

  def delete_room(client, request, token) do
    make_request(client, request, token, "/twirp/livekit.RoomService/DeleteRoom")
  end

  def list_participants(client, request, token) do
    make_request(client, request, token, "/twirp/livekit.RoomService/ListParticipants")
  end

  def remove_participant(client, request, token) do
    make_request(client, request, token, "/twirp/livekit.RoomService/RemoveParticipant")
  end

  def mute_published_track(client, request, token) do
    make_request(client, request, token, "/twirp/livekit.RoomService/MutePublishedTrack")
  end

  defp make_request(client, request, token, path) do
    headers = [{"authorization", "Bearer #{token}"}]
    body = Protobuf.encode(request)

    case Tesla.post(client, path, body, headers: headers) do
      {:ok, %Tesla.Env{status: 200, body: response_body}} ->
        {:ok, Protobuf.decode(response_body, response_type_for(path))}

      {:ok, %Tesla.Env{body: error_body}} ->
        {:error, parse_twirp_error(error_body)}

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp response_type_for("/twirp/livekit.RoomService/CreateRoom"), do: Livekit.Room

  defp response_type_for("/twirp/livekit.RoomService/ListRooms"),
    do: Livekit.ListRoomsResponse

  defp response_type_for("/twirp/livekit.RoomService/DeleteRoom"),
    do: Livekit.DeleteRoomResponse

  defp response_type_for("/twirp/livekit.RoomService/ListParticipants"),
    do: Livekit.ListParticipantsResponse

  defp response_type_for("/twirp/livekit.RoomService/RemoveParticipant"),
    do: Livekit.RemoveParticipantResponse

  defp response_type_for("/twirp/livekit.RoomService/MutePublishedTrack"),
    do: Livekit.MuteRoomTrackResponse

  defp parse_twirp_error(error_body) do
    case Jason.decode(error_body) do
      {:ok, %{"code" => code, "msg" => msg}} ->
        %{code: String.to_atom(code), msg: msg}

      _ ->
        %{code: :internal, msg: "Unknown error"}
    end
  end
end

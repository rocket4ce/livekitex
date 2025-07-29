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
        case path do
          "/twirp/livekit.RoomService/CreateRoom" ->
            {:ok, Protobuf.decode(response_body, Livekit.Room)}

          "/twirp/livekit.RoomService/ListRooms" ->
            {:ok, Protobuf.decode(response_body, Livekit.ListRoomsResponse)}

          "/twirp/livekit.RoomService/DeleteRoom" ->
            {:ok, Protobuf.decode(response_body, Livekit.DeleteRoomResponse)}

          "/twirp/livekit.RoomService/ListParticipants" ->
            {:ok, Protobuf.decode(response_body, Livekit.ListParticipantsResponse)}

          "/twirp/livekit.RoomService/RemoveParticipant" ->
            {:ok, Protobuf.decode(response_body, Livekit.RemoveParticipantResponse)}

          "/twirp/livekit.RoomService/MutePublishedTrack" ->
            {:ok, Protobuf.decode(response_body, Livekit.MuteRoomTrackResponse)}
        end

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
        %{code: :internal, msg: "Unknown error"}
    end
  end
end

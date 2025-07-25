defmodule Livekitex.RoomService do
  @behaviour Livekitex.RoomServiceBehaviour
  @moduledoc """
  Provides functionality to interact with the LiveKit RoomService API.
  """

  alias Livekitex.AccessToken
  alias Livekitex.Grants
  alias Livekitex.GrpcUtils

  require Logger

  defstruct api_key: nil,
            api_secret: nil,
            host: "localhost",
            port: 7881,
            channel: nil

  @type t :: %__MODULE__{
          api_key: String.t(),
          api_secret: String.t(),
          host: String.t(),
          port: integer(),
          channel: GRPC.Channel.t() | nil
        }

  @doc """
  Creates a new RoomService client.

  ## Parameters

    - `api_key`: The API key for your LiveKit project.
    - `api_secret`: The API secret for your LiveKit project.
    - `options`: A keyword list of options.
      - `host`: The host of the LiveKit server. Defaults to "localhost".
      - `port`: The port of the LiveKit server. Defaults to 7880.

  ## Examples

      iex> Livekitex.RoomService.create("api_key", "api_secret")
      %Livekitex.RoomService{
        api_key: "api_key",
        api_secret: "api_secret",
        host: "localhost",
        port: 7880
      }
  """
  def create(api_key, api_secret, options \\ []) do
    %__MODULE__{
      api_key: api_key,
      api_secret: api_secret,
      host: Keyword.get(options, :host, "localhost"),
      port: Keyword.get(options, :port, 7880)
    }
  end

  @doc """
  Creates a new room.

  ## Parameters

    - `room_service`: The RoomService client.
    - `name`: The name of the room.
    - `options`: A keyword list of options.
      - `empty_timeout`: Room timeout when empty (seconds)
      - `departure_timeout`: Timeout after participant departure (seconds)
      - `max_participants`: Maximum number of participants
      - `metadata`: Room metadata
      - `min_playout_delay`: Minimum playout delay (ms)
      - `max_playout_delay`: Maximum playout delay (ms)
      - `sync_streams`: Whether to sync streams

  ## Examples

      iex> room_service = Livekitex.RoomService.create("devkey", "secret")
      iex> Livekitex.RoomService.create_room(room_service, "test-room")
      {:ok, %Livekitex.Room{}}
  """
  def create_room(%__MODULE__{} = room_service, name, options \\ []) do
    with {:ok, channel} <- ensure_channel(room_service),
         {:ok, token} <- create_room_token(room_service),
         request <- build_create_room_request(name, options),
         headers <- GrpcUtils.auth_headers(token) do
      case Livekit.RoomService.Stub.create_room(channel, request, metadata: headers) do
        {:ok, proto_room} ->
          {:ok, GrpcUtils.proto_to_room(proto_room)}

        error ->
          GrpcUtils.handle_grpc_response(error)
      end
    end
  end

  @doc """
  Deletes a room.

  ## Parameters

    - `room_service`: The RoomService client.
    - `room_name`: The name of the room to delete.

  ## Examples

      iex> room_service = Livekitex.RoomService.create("devkey", "secret")
      iex> Livekitex.RoomService.delete_room(room_service, "test-room")
      :ok
  """
  def delete_room(%__MODULE__{} = room_service, room_name) do
    with {:ok, channel} <- ensure_channel(room_service),
         {:ok, token} <- create_room_token(room_service),
         request <- %Livekit.DeleteRoomRequest{room: room_name},
         headers <- GrpcUtils.auth_headers(token) do
      case Livekit.RoomService.Stub.delete_room(channel, request, metadata: headers) do
        {:ok, _response} -> :ok
        error -> GrpcUtils.handle_grpc_response(error)
      end
    end
  end

  @doc """
  Lists all rooms.

  ## Parameters

    - `room_service`: The RoomService client.
    - `options`: A keyword list of options.
      - `names`: List of specific room names to filter by

  ## Examples

      iex> room_service = Livekitex.RoomService.create("devkey", "secret")
      iex> Livekitex.RoomService.list_rooms(room_service)
      {:ok, []}
  """
  def list_rooms(%__MODULE__{} = room_service, options \\ []) do
    with {:ok, channel} <- ensure_channel(room_service),
         {:ok, token} <- create_room_list_token(room_service),
         request <- %Livekit.ListRoomsRequest{names: Keyword.get(options, :names, [])},
         headers <- GrpcUtils.auth_headers(token) do
      case Livekit.RoomService.Stub.list_rooms(channel, request, metadata: headers) do
        {:ok, %Livekit.ListRoomsResponse{rooms: rooms}} ->
          {:ok, Enum.map(rooms, &GrpcUtils.proto_to_room/1)}

        error ->
          GrpcUtils.handle_grpc_response(error)
      end
    end
  end

  @doc """
  Lists participants in a room.

  ## Parameters

    - `room_service`: The RoomService client.
    - `room_name`: The name of the room.

  ## Examples

      iex> room_service = Livekitex.RoomService.create("devkey", "secret")
      iex> Livekitex.RoomService.list_participants(room_service, "test-room")
      {:ok, []}
  """
  def list_participants(%__MODULE__{} = room_service, room_name) do
    with {:ok, channel} <- ensure_channel(room_service),
         {:ok, token} <- create_room_admin_token(room_service, room_name),
         request <- %Livekit.ListParticipantsRequest{room: room_name},
         headers <- GrpcUtils.auth_headers(token) do
      case Livekit.RoomService.Stub.list_participants(channel, request, metadata: headers) do
        {:ok, %Livekit.ListParticipantsResponse{participants: participants}} ->
          {:ok, Enum.map(participants, &GrpcUtils.proto_to_participant/1)}

        error ->
          GrpcUtils.handle_grpc_response(error)
      end
    end
  end

  @doc """
  Removes a participant from a room.

  ## Parameters

    - `room_service`: The RoomService client.
    - `room_name`: The name of the room.
    - `identity`: The identity of the participant to remove.

  ## Examples

      iex> room_service = Livekitex.RoomService.create("devkey", "secret")
      iex> Livekitex.RoomService.remove_participant(room_service, "test-room", "user123")
      :ok
  """
  def remove_participant(%__MODULE__{} = room_service, room_name, identity) do
    with {:ok, channel} <- ensure_channel(room_service),
         {:ok, token} <- create_room_admin_token(room_service, room_name),
         request <- %Livekit.RoomParticipantIdentity{room: room_name, identity: identity},
         headers <- GrpcUtils.auth_headers(token) do
      case Livekit.RoomService.Stub.remove_participant(channel, request, metadata: headers) do
        {:ok, _response} -> :ok
        error -> GrpcUtils.handle_grpc_response(error)
      end
    end
  end

  @doc """
  Mutes or unmutes a published track.

  ## Parameters

    - `room_service`: The RoomService client.
    - `room_name`: The name of the room.
    - `identity`: The identity of the participant.
    - `track_sid`: The SID of the track to mute/unmute.
    - `muted`: Whether to mute (true) or unmute (false) the track.

  ## Examples

      iex> room_service = Livekitex.RoomService.create("devkey", "secret")
      iex> Livekitex.RoomService.mute_published_track(room_service, "test-room", "user123", "track_sid", true)
      {:ok, %{}}
  """
  def mute_published_track(%__MODULE__{} = room_service, room_name, identity, track_sid, muted) do
    with {:ok, channel} <- ensure_channel(room_service),
         {:ok, token} <- create_room_admin_token(room_service, room_name),
         request <- %Livekit.MuteRoomTrackRequest{
           room: room_name,
           identity: identity,
           track_sid: track_sid,
           muted: muted
         },
         headers <- GrpcUtils.auth_headers(token) do
      case Livekit.RoomService.Stub.mute_published_track(channel, request, metadata: headers) do
        {:ok, %Livekit.MuteRoomTrackResponse{track: track}} ->
          {:ok, GrpcUtils.proto_to_track(track)}

        error ->
          GrpcUtils.handle_grpc_response(error)
      end
    end
  end

  # Private helper functions

  defp ensure_channel(%__MODULE__{channel: nil} = room_service) do
    case GrpcUtils.create_channel(room_service.host, room_service.port) do
      {:ok, channel} -> {:ok, channel}
      error -> error
    end
  end

  defp ensure_channel(%__MODULE__{channel: channel}), do: {:ok, channel}

  defp create_room_token(%__MODULE__{api_key: api_key, api_secret: api_secret}) do
    video_grant = %Grants.VideoGrant{room_create: true}
    grants = %Grants.ClaimGrant{video: video_grant}

    api_key
    |> AccessToken.create(api_secret, grants: grants)
    |> AccessToken.set_video_grant(video_grant)
    |> AccessToken.to_jwt()
    |> case do
      {:ok, jwt, _claims} -> {:ok, jwt}
      error -> error
    end
  end

  defp create_room_list_token(%__MODULE__{api_key: api_key, api_secret: api_secret}) do
    video_grant = %Grants.VideoGrant{room_list: true}
    grants = %Grants.ClaimGrant{video: video_grant}

    api_key
    |> AccessToken.create(api_secret, grants: grants)
    |> AccessToken.set_video_grant(video_grant)
    |> AccessToken.to_jwt()
    |> case do
      {:ok, jwt, _claims} -> {:ok, jwt}
      error -> error
    end
  end

  defp create_room_admin_token(%__MODULE__{api_key: api_key, api_secret: api_secret}, room_name) do
    video_grant = %Grants.VideoGrant{room_admin: true, room: room_name}
    grants = %Grants.ClaimGrant{video: video_grant}

    api_key
    |> AccessToken.create(api_secret, grants: grants)
    |> AccessToken.set_video_grant(video_grant)
    |> AccessToken.to_jwt()
    |> case do
      {:ok, jwt, _claims} -> {:ok, jwt}
      error -> error
    end
  end

  defp build_create_room_request(name, options) do
    %Livekit.CreateRoomRequest{
      name: name,
      empty_timeout: Keyword.get(options, :empty_timeout),
      departure_timeout: Keyword.get(options, :departure_timeout),
      max_participants: Keyword.get(options, :max_participants),
      metadata: Keyword.get(options, :metadata),
      min_playout_delay: Keyword.get(options, :min_playout_delay),
      max_playout_delay: Keyword.get(options, :max_playout_delay),
      sync_streams: Keyword.get(options, :sync_streams)
    }
  end
end

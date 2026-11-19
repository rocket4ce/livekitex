defmodule Livekitex.RoomService do
  @moduledoc """
  Room and participant management (`livekit.RoomService`).

  Every function takes a `Livekitex.Client` as first argument and returns
  `{:ok, result}` (or `:ok`) on success and `{:error, %Livekitex.Error{}}` on failure.
  Results are the generated protobuf structs under `Livekitex.Proto.Livekit`.

      client = Livekitex.client()
      {:ok, room} = Livekitex.RoomService.create_room(client, "standup", empty_timeout: 300)
      {:ok, participants} = Livekitex.RoomService.list_participants(client, "standup")

  The trailing `opts` of every function also accepts the call options `:timeout`,
  `:retry` and `:request_id` (see `Livekitex.Twirp`).
  """

  import Livekitex.Service

  alias Livekitex.Client

  alias Livekitex.Proto.Livekit.{
    CreateRoomRequest,
    DeleteRoomRequest,
    DeleteRoomResponse,
    ForwardParticipantRequest,
    ForwardParticipantResponse,
    ListParticipantsRequest,
    ListParticipantsResponse,
    ListRoomsRequest,
    ListRoomsResponse,
    MoveParticipantRequest,
    MoveParticipantResponse,
    MuteRoomTrackRequest,
    MuteRoomTrackResponse,
    ParticipantInfo,
    PerformRpcRequest,
    PerformRpcResponse,
    RemoveParticipantResponse,
    Room,
    RoomParticipantIdentity,
    SendDataRequest,
    SendDataResponse,
    TrackInfo,
    UpdateParticipantRequest,
    UpdateRoomMetadataRequest,
    UpdateSubscriptionsRequest,
    UpdateSubscriptionsResponse
  }

  @service "RoomService"

  @type result(t) :: {:ok, t} | {:error, Livekitex.Error.t()}

  @doc """
  Builds a client. Kept for compatibility with 0.1.x; prefer `Livekitex.Client.new/1`.
  """
  @deprecated "Use Livekitex.Client.new/1 instead"
  @spec create(String.t(), String.t(), String.t()) :: Client.t()
  def create(url, api_key, api_secret),
    do: Client.new(url: url, api_key: api_key, api_secret: api_secret)

  @doc """
  Creates a room, or returns the existing one with the same name.

  `opts` accepts any `CreateRoomRequest` field: `:empty_timeout`, `:departure_timeout`,
  `:max_participants`, `:metadata`, `:room_preset`, `:tags`, `:egress`, `:agents`,
  `:min_playout_delay`, `:max_playout_delay`, `:sync_streams`, `:replay_enabled`, ...

      create_room(client, "support", agents: [[agent_name: "support-agent"]])
  """
  @spec create_room(Client.t(), String.t() | CreateRoomRequest.t(), keyword()) :: result(Room.t())
  def create_room(client, name_or_request, opts \\ [])

  def create_room(client, %CreateRoomRequest{} = request, opts) do
    call_opts = call_opts!(opts)

    rpc(
      client,
      @service,
      "CreateRoom",
      CreateRoomRequest,
      request,
      Room,
      [video: [room_create: true]],
      call_opts
    )
  end

  def create_room(client, name, opts) when is_binary(name) do
    {call_opts, fields} = split_opts(opts)
    request = Keyword.put(fields, :name, name)

    rpc(
      client,
      @service,
      "CreateRoom",
      CreateRoomRequest,
      request,
      Room,
      [video: [room_create: true]],
      call_opts
    )
  end

  @doc """
  Lists active rooms. Pass `names: [...]` to only return those rooms.
  """
  @spec list_rooms(Client.t(), keyword()) :: result([Room.t()])
  def list_rooms(client, opts \\ []) do
    {call_opts, fields} = split_opts(opts)

    client
    |> rpc(
      @service,
      "ListRooms",
      ListRoomsRequest,
      fields,
      ListRoomsResponse,
      [video: [room_list: true]],
      call_opts
    )
    |> map_ok(& &1.rooms)
  end

  @doc "Deletes a room, disconnecting all participants."
  @spec delete_room(Client.t(), String.t(), keyword()) :: :ok | {:error, Livekitex.Error.t()}
  def delete_room(client, room, opts \\ []) do
    call_opts = call_opts!(opts)

    client
    |> rpc(
      @service,
      "DeleteRoom",
      DeleteRoomRequest,
      [room: room],
      DeleteRoomResponse,
      [video: [room_create: true]],
      call_opts
    )
    |> to_ok()
  end

  @doc "Updates the room metadata. Returns the updated room."
  @spec update_room_metadata(Client.t(), String.t(), String.t(), keyword()) :: result(Room.t())
  def update_room_metadata(client, room, metadata, opts \\ []) do
    call_opts = call_opts!(opts)
    fields = [room: room, metadata: metadata]

    rpc(
      client,
      @service,
      "UpdateRoomMetadata",
      UpdateRoomMetadataRequest,
      fields,
      Room,
      admin(room),
      call_opts
    )
  end

  @doc "Lists the participants of a room."
  @spec list_participants(Client.t(), String.t(), keyword()) :: result([ParticipantInfo.t()])
  def list_participants(client, room, opts \\ []) do
    call_opts = call_opts!(opts)

    client
    |> rpc(
      @service,
      "ListParticipants",
      ListParticipantsRequest,
      [room: room],
      ListParticipantsResponse,
      admin(room),
      call_opts
    )
    |> map_ok(& &1.participants)
  end

  @doc "Gets a participant by identity."
  @spec get_participant(Client.t(), String.t(), String.t(), keyword()) ::
          result(ParticipantInfo.t())
  def get_participant(client, room, identity, opts \\ []) do
    call_opts = call_opts!(opts)
    fields = [room: room, identity: identity]

    rpc(
      client,
      @service,
      "GetParticipant",
      RoomParticipantIdentity,
      fields,
      ParticipantInfo,
      admin(room),
      call_opts
    )
  end

  @doc """
  Removes a participant from a room.

  Pass `revoke_token_ts: unix_seconds` to also revoke tokens issued before that time,
  so the participant cannot rejoin with an old token.
  """
  @spec remove_participant(Client.t(), String.t(), String.t(), keyword()) ::
          :ok | {:error, Livekitex.Error.t()}
  def remove_participant(client, room, identity, opts \\ []) do
    {call_opts, fields} = split_opts(opts)
    fields = Keyword.merge(fields, room: room, identity: identity)

    client
    |> rpc(
      @service,
      "RemoveParticipant",
      RoomParticipantIdentity,
      fields,
      RemoveParticipantResponse,
      admin(room),
      call_opts
    )
    |> to_ok()
  end

  @doc "Mutes or unmutes a published track. Returns the updated track."
  @spec mute_published_track(Client.t(), String.t(), String.t(), String.t(), boolean(), keyword()) ::
          result(TrackInfo.t())
  def mute_published_track(client, room, identity, track_sid, muted, opts \\ []) do
    call_opts = call_opts!(opts)
    fields = [room: room, identity: identity, track_sid: track_sid, muted: muted]

    client
    |> rpc(
      @service,
      "MutePublishedTrack",
      MuteRoomTrackRequest,
      fields,
      MuteRoomTrackResponse,
      admin(room),
      call_opts
    )
    |> map_ok(& &1.track)
  end

  @doc """
  Updates a participant's metadata, name, attributes or permissions.

      update_participant(client, "room", "alice",
        attributes: %{"role" => "host"},
        permission: [can_publish: true, can_subscribe: true, can_publish_data: true]
      )
  """
  @spec update_participant(Client.t(), String.t(), String.t(), keyword()) ::
          result(ParticipantInfo.t())
  def update_participant(client, room, identity, opts) do
    {call_opts, fields} = split_opts(opts)
    fields = Keyword.merge(fields, room: room, identity: identity)

    rpc(
      client,
      @service,
      "UpdateParticipant",
      UpdateParticipantRequest,
      fields,
      ParticipantInfo,
      admin(room),
      call_opts
    )
  end

  @doc """
  Subscribes or unsubscribes a participant to tracks.

  Use `participant_tracks: [[participant_sid: "PA_...", track_sids: [...]]]` in `opts`
  to target tracks by publisher.
  """
  @spec update_subscriptions(
          Client.t(),
          String.t(),
          String.t(),
          [String.t()],
          boolean(),
          keyword()
        ) ::
          :ok | {:error, Livekitex.Error.t()}
  def update_subscriptions(client, room, identity, track_sids, subscribe, opts \\ []) do
    {call_opts, fields} = split_opts(opts)

    fields =
      Keyword.merge(fields,
        room: room,
        identity: identity,
        track_sids: track_sids,
        subscribe: subscribe
      )

    client
    |> rpc(
      @service,
      "UpdateSubscriptions",
      UpdateSubscriptionsRequest,
      fields,
      UpdateSubscriptionsResponse,
      admin(room),
      call_opts
    )
    |> to_ok()
  end

  @doc """
  Sends a data packet to participants in a room.

  ## Options

    * `:kind` - `:RELIABLE` (default) or `:LOSSY`
    * `:destination_identities` - list of identities (all participants when empty)
    * `:topic` - topic string

  A random nonce is added so LiveKit can deduplicate the packet. Not retried by default.
  """
  @spec send_data(Client.t(), String.t(), binary(), keyword()) ::
          :ok | {:error, Livekitex.Error.t()}
  def send_data(client, room, data, opts \\ []) do
    {call_opts, fields} = split_opts(opts)

    fields =
      fields
      |> Keyword.put_new(:kind, :RELIABLE)
      |> Keyword.put_new_lazy(:nonce, fn -> :crypto.strong_rand_bytes(16) end)
      |> Keyword.merge(room: room, data: data)

    client
    |> rpc(
      @service,
      "SendData",
      SendDataRequest,
      fields,
      SendDataResponse,
      admin(room),
      no_retry(call_opts)
    )
    |> to_ok()
  end

  @doc """
  Forwards a participant to another room: the participant stays in `room` and also
  appears in `destination_room`. Not retried by default.
  """
  @spec forward_participant(Client.t(), String.t(), String.t(), String.t(), keyword()) ::
          :ok | {:error, Livekitex.Error.t()}
  def forward_participant(client, room, identity, destination_room, opts \\ []) do
    call_opts = call_opts!(opts)
    fields = [room: room, identity: identity, destination_room: destination_room]

    client
    |> rpc(
      @service,
      "ForwardParticipant",
      ForwardParticipantRequest,
      fields,
      ForwardParticipantResponse,
      admin(room, destination_room),
      no_retry(call_opts)
    )
    |> to_ok()
  end

  @doc "Moves a participant from `room` to `destination_room`. Not retried by default."
  @spec move_participant(Client.t(), String.t(), String.t(), String.t(), keyword()) ::
          :ok | {:error, Livekitex.Error.t()}
  def move_participant(client, room, identity, destination_room, opts \\ []) do
    call_opts = call_opts!(opts)
    fields = [room: room, identity: identity, destination_room: destination_room]

    client
    |> rpc(
      @service,
      "MoveParticipant",
      MoveParticipantRequest,
      fields,
      MoveParticipantResponse,
      admin(room, destination_room),
      no_retry(call_opts)
    )
    |> to_ok()
  end

  @doc """
  Performs an RPC call on a participant (for example an agent) and returns its
  response payload.

  ## Options

    * `:response_timeout_ms` - how long LiveKit waits for the participant's response.
      The HTTP timeout is extended accordingly unless `:timeout` is given.

  Not retried by default.
  """
  @spec perform_rpc(Client.t(), String.t(), String.t(), String.t(), String.t(), keyword()) ::
          result(String.t())
  def perform_rpc(client, room, destination_identity, method, payload, opts \\ []) do
    {call_opts, fields} = split_opts(opts)

    call_opts =
      case fields[:response_timeout_ms] do
        ms when is_integer(ms) and ms > 0 -> Keyword.put_new(call_opts, :timeout, ms + 5_000)
        _ -> call_opts
      end

    fields =
      Keyword.merge(fields,
        room: room,
        destination_identity: destination_identity,
        method: method,
        payload: payload
      )

    client
    |> rpc(
      @service,
      "PerformRpc",
      PerformRpcRequest,
      fields,
      PerformRpcResponse,
      admin(room),
      no_retry(call_opts)
    )
    |> map_ok(& &1.payload)
  end

  defp admin(room), do: [video: [room_admin: true, room: room]]

  defp admin(room, destination_room),
    do: [video: [room_admin: true, room: room, destination_room: destination_room]]
end

defmodule Livekitex.EgressService do
  @moduledoc """
  Recording and streaming (`livekit.Egress`).

  All calls use a token with the `roomRecord` grant. Requests can be given as the
  generated struct or as a keyword list (nested messages as keyword lists, oneof
  members by field name).

  ## Unified API (`start_egress/3`)

      Livekitex.EgressService.start_egress(client, "standup",
        template: [layout: "grid"],
        outputs: [[file: [filepath: "recordings/{room_name}-{time}.mp4"]]]
      )

  ## Legacy APIs

      Livekitex.EgressService.start_room_composite_egress(client, "standup",
        layout: "speaker",
        file_outputs: [[filepath: "recordings/standup.mp4"]]
      )

  `start_*` calls and `update_stream/3` are never retried automatically (a retry could
  start a second recording, or re-add a stream URL). Pass `retry: true` to override.
  """

  import Livekitex.Service

  alias Livekitex.Client

  alias Livekitex.Proto.Livekit.{
    EgressInfo,
    ListEgressRequest,
    ListEgressResponse,
    ParticipantEgressRequest,
    RoomCompositeEgressRequest,
    StartEgressRequest,
    StopEgressRequest,
    TrackCompositeEgressRequest,
    TrackEgressRequest,
    UpdateLayoutRequest,
    UpdateStreamRequest,
    WebEgressRequest
  }

  @service "Egress"
  @grants [video: [room_record: true]]

  @type result(t) :: {:ok, t} | {:error, Livekitex.Error.t()}

  @doc "Builds a client. Kept for compatibility with 0.1.x; prefer `Livekitex.Client.new/1`."
  @deprecated "Use Livekitex.Client.new/1 instead"
  def create(url, api_key, api_secret),
    do: Client.new(url: url, api_key: api_key, api_secret: api_secret)

  @doc """
  Starts an egress with the unified `StartEgress` API.

  `room_or_request` is the room name (with the remaining fields in `opts`) or a full
  `StartEgressRequest`.
  """
  @spec start_egress(Client.t(), String.t() | StartEgressRequest.t() | keyword(), keyword()) ::
          result(EgressInfo.t())
  def start_egress(client, room_or_request, opts \\ []),
    do: start(client, "StartEgress", StartEgressRequest, room_or_request, opts)

  @doc "Starts a room composite egress (records or streams the whole room)."
  @spec start_room_composite_egress(Client.t(), String.t() | struct() | keyword(), keyword()) ::
          result(EgressInfo.t())
  def start_room_composite_egress(client, room_or_request, opts \\ []),
    do:
      start(client, "StartRoomCompositeEgress", RoomCompositeEgressRequest, room_or_request, opts)

  @doc "Starts a web egress (records any web page). Pass the request as a keyword list or struct."
  @spec start_web_egress(Client.t(), struct() | keyword(), keyword()) :: result(EgressInfo.t())
  def start_web_egress(client, request, opts \\ []),
    do: start(client, "StartWebEgress", WebEgressRequest, request, opts)

  @doc "Starts a participant egress (records one participant's tracks)."
  @spec start_participant_egress(Client.t(), String.t() | struct() | keyword(), keyword()) ::
          result(EgressInfo.t())
  def start_participant_egress(client, room_or_request, opts \\ []),
    do: start(client, "StartParticipantEgress", ParticipantEgressRequest, room_or_request, opts)

  @doc "Starts a track composite egress (one audio and/or one video track)."
  @spec start_track_composite_egress(Client.t(), String.t() | struct() | keyword(), keyword()) ::
          result(EgressInfo.t())
  def start_track_composite_egress(client, room_or_request, opts \\ []),
    do:
      start(
        client,
        "StartTrackCompositeEgress",
        TrackCompositeEgressRequest,
        room_or_request,
        opts
      )

  @doc "Starts a track egress (exports a single track without transcoding)."
  @spec start_track_egress(Client.t(), String.t() | struct() | keyword(), keyword()) ::
          result(EgressInfo.t())
  def start_track_egress(client, room_or_request, opts \\ []),
    do: start(client, "StartTrackEgress", TrackEgressRequest, room_or_request, opts)

  @doc "Changes the layout of a running room composite egress."
  @spec update_layout(Client.t(), String.t(), String.t(), keyword()) :: result(EgressInfo.t())
  def update_layout(client, egress_id, layout, opts \\ []) do
    call_opts = call_opts!(opts)
    fields = [egress_id: egress_id, layout: layout]

    rpc(
      client,
      @service,
      "UpdateLayout",
      UpdateLayoutRequest,
      fields,
      EgressInfo,
      @grants,
      call_opts
    )
  end

  @doc """
  Adds or removes stream output URLs of a running egress.

      update_stream(client, egress_id, add_output_urls: ["rtmp://..."], remove_output_urls: [])

  `add_output_urls` does not deduplicate, so a retried call can report that the stream
  already exists even though the first attempt succeeded. Not retried by default; pass
  `retry: true` to override.
  """
  @spec update_stream(Client.t(), String.t(), keyword()) :: result(EgressInfo.t())
  def update_stream(client, egress_id, opts) do
    {call_opts, fields} = split_opts(opts)
    fields = Keyword.put(fields, :egress_id, egress_id)

    rpc(
      client,
      @service,
      "UpdateStream",
      UpdateStreamRequest,
      fields,
      EgressInfo,
      @grants,
      no_retry(call_opts)
    )
  end

  @doc """
  Lists egresses.

  ## Options

    * `:room_name` - only egresses of this room
    * `:egress_id` - a single egress
    * `:active` - only active egresses
    * `:page_token` - `[token: next_page_token]` from a previous page

  Returns the full `ListEgressResponse` (`items` and `next_page_token`).
  """
  @spec list_egress(Client.t(), keyword()) :: result(ListEgressResponse.t())
  def list_egress(client, opts \\ []) do
    {call_opts, fields} = split_opts(opts)

    client
    |> rpc(
      @service,
      "ListEgress",
      ListEgressRequest,
      fields,
      ListEgressResponse,
      @grants,
      call_opts
    )
  end

  @doc "Stops an egress."
  @spec stop_egress(Client.t(), String.t(), keyword()) :: result(EgressInfo.t())
  def stop_egress(client, egress_id, opts \\ []) do
    call_opts = call_opts!(opts)

    rpc(
      client,
      @service,
      "StopEgress",
      StopEgressRequest,
      [egress_id: egress_id],
      EgressInfo,
      @grants,
      call_opts
    )
  end

  defp start(client, method, module, room_or_request, opts) do
    {call_opts, fields} = split_opts(opts)

    request =
      case room_or_request do
        room when is_binary(room) -> Keyword.put(fields, :room_name, room)
        other -> merge_fields(other, fields)
      end

    rpc(client, @service, method, module, request, EgressInfo, @grants, no_retry(call_opts))
  end
end

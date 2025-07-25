defmodule Livekitex.TwirpUtils do
  @moduledoc """
  Utilities for handling Twirp communication and errors.
  """

  require Logger

  @doc """
  Handles Twirp responses and converts them to standard Elixir patterns.
  """
  def handle_twirp_response({:ok, response}), do: {:ok, response}

  def handle_twirp_response({:error, %Twirp.Error{} = error}) do
    Logger.error("Twirp error: #{inspect(error)}")
    {:error, format_twirp_error(error)}
  end

  def handle_twirp_response({:error, reason}) do
    Logger.error("Twirp communication error: #{inspect(reason)}")
    {:error, {:twirp_error, reason}}
  end

  @doc """
  Formats Twirp errors into more user-friendly error tuples.
  """
  def format_twirp_error(%Twirp.Error{code: code, msg: message}) do
    case code do
      :unauthenticated -> {:unauthenticated, message}
      :permission_denied -> {:permission_denied, message}
      :not_found -> {:not_found, message}
      :already_exists -> {:already_exists, message}
      :invalid_argument -> {:invalid_argument, message}
      :unavailable -> {:unavailable, message}
      :deadline_exceeded -> {:deadline_exceeded, message}
      :internal -> {:internal_error, message}
      _ -> {:twirp_error, {code, message}}
    end
  end

  @doc """
  Creates Tesla client configuration for Twirp requests.
  """
  def create_client(base_url, token \\ nil, opts \\ []) do
    middleware = [
      {Tesla.Middleware.BaseUrl, base_url},
      {Tesla.Middleware.Headers,
       [
         {"content-type", "application/protobuf"}
       ]},
      {Tesla.Middleware.Timeout, timeout: Keyword.get(opts, :timeout, 30_000)}
    ]

    middleware =
      if token do
        [{Tesla.Middleware.Headers, [{"authorization", "Bearer #{token}"}]} | middleware]
      else
        middleware
      end

    adapter = {Tesla.Adapter.Finch, name: Livekitex.Finch}

    Tesla.client(middleware, adapter)
  end

  @doc """
  Converts a protobuf Room to our internal Room struct.
  """
  def proto_to_room(%Livekit.Room{} = proto_room) do
    %Livekitex.Room{
      name: proto_room.name,
      sid: proto_room.sid,
      empty_timeout: proto_room.empty_timeout,
      departure_timeout: proto_room.departure_timeout,
      max_participants: proto_room.max_participants,
      creation_time: proto_room.creation_time,
      turn_password: proto_room.turn_password,
      enabled_codecs: Enum.map(proto_room.enabled_codecs || [], &codec_to_map/1),
      metadata: proto_room.metadata,
      num_participants: proto_room.num_participants,
      num_publishers: proto_room.num_publishers,
      active_recording: proto_room.active_recording,
      version: version_to_map(proto_room.version)
    }
  end

  @doc """
  Converts a protobuf ParticipantInfo to a map.
  """
  def proto_to_participant(%Livekit.ParticipantInfo{} = proto_participant) do
    %{
      sid: proto_participant.sid,
      identity: proto_participant.identity,
      state: proto_participant.state,
      tracks: Enum.map(proto_participant.tracks || [], &track_to_map/1),
      metadata: proto_participant.metadata,
      joined_at: proto_participant.joined_at,
      name: proto_participant.name,
      version: proto_participant.version,
      permission: permission_to_map(proto_participant.permission),
      region: proto_participant.region,
      is_publisher: proto_participant.is_publisher,
      kind: proto_participant.kind,
      attributes: Map.new(proto_participant.attributes || %{}),
      disconnected_at: proto_participant.disconnected_at
    }
  end

  @doc """
  Converts a protobuf TrackInfo to a map.
  """
  def proto_to_track(%Livekit.TrackInfo{} = proto_track) do
    track_to_map(proto_track)
  end

  # Private helper functions

  defp codec_to_map(%Livekit.Codec{} = codec) do
    %{
      mime: codec.mime,
      fmtp_line: codec.fmtp_line
    }
  end

  defp codec_to_map(_), do: %{}

  defp track_to_map(%Livekit.TrackInfo{} = track) do
    %{
      sid: track.sid,
      type: track.type,
      name: track.name,
      muted: track.muted,
      width: track.width,
      height: track.height,
      simulcast: track.simulcast,
      disable_dtx: track.disable_dtx,
      source: track.source,
      layers: Enum.map(track.layers || [], &layer_to_map/1),
      mime_type: track.mime_type,
      mid: track.mid,
      codecs: Enum.map(track.codecs || [], &codec_to_map/1),
      stereo: track.stereo,
      disable_red: track.disable_red,
      encryption: track.encryption,
      stream: track.stream
    }
  end

  defp track_to_map(_), do: %{}

  defp layer_to_map(%Livekit.VideoLayer{} = layer) do
    %{
      quality: layer.quality,
      width: layer.width,
      height: layer.height,
      bitrate: layer.bitrate,
      ssrc: layer.ssrc
    }
  end

  defp layer_to_map(_), do: %{}

  defp permission_to_map(%Livekit.ParticipantPermission{} = permission) do
    %{
      can_subscribe: permission.can_subscribe,
      can_publish: permission.can_publish,
      can_publish_data: permission.can_publish_data,
      can_publish_sources: permission.can_publish_sources || [],
      hidden: permission.hidden,
      recorder: permission.recorder,
      can_update_metadata: permission.can_update_metadata,
      agent: permission.agent
    }
  end

  defp permission_to_map(_), do: %{}

  defp version_to_map(%Livekit.TimedVersion{} = version) do
    %{
      unix_micro: version.unix_micro,
      ticks: version.ticks
    }
  end

  defp version_to_map(_), do: nil
end

defmodule Livekitex.GrpcUtils do
  @moduledoc """
  Utilities for handling gRPC communication and errors.
  """

  require Logger

  @doc """
  Handles gRPC responses and converts them to standard Elixir patterns.
  """
  def handle_grpc_response({:ok, response}), do: {:ok, response}

  def handle_grpc_response({:error, %GRPC.RPCError{} = error}) do
    Logger.error("gRPC error: #{inspect(error)}")
    {:error, format_grpc_error(error)}
  end

  def handle_grpc_response({:error, reason}) do
    Logger.error("gRPC communication error: #{inspect(reason)}")
    {:error, {:grpc_error, reason}}
  end

  @doc """
  Handles gRPC errors and converts them to standard Elixir patterns.
  This is an alias for handle_grpc_response for backward compatibility.
  """
  def handle_grpc_error(error), do: handle_grpc_response(error)

  @doc """
  Formats gRPC errors into more user-friendly error tuples.
  """
  def format_grpc_error(%GRPC.RPCError{status: status, message: message}) do
    case status do
      :unauthenticated -> {:unauthenticated, message}
      16 -> {:unauthenticated, message}
      :permission_denied -> {:permission_denied, message}
      7 -> {:permission_denied, message}
      :not_found -> {:not_found, message}
      5 -> {:not_found, message}
      :already_exists -> {:already_exists, message}
      6 -> {:already_exists, message}
      :invalid_argument -> {:invalid_argument, message}
      3 -> {:invalid_argument, message}
      :unavailable -> {:unavailable, message}
      14 -> {:unavailable, message}
      :deadline_exceeded -> {:deadline_exceeded, message}
      4 -> {:deadline_exceeded, message}
      :internal -> {:internal_error, message}
      13 -> handle_status_13_error(message)
      2 -> {:internal_error, message}
      _ -> {:grpc_error, {status, message}}
    end
  end

  # Helper function to handle status 13 errors with different message patterns
  defp handle_status_13_error(message) do
    cond do
      String.contains?(message, "stream_error") -> {:connection_failed, message}
      String.contains?(message, "connection_error") -> {:connection_failed, message}
      true -> {:internal_error, message}
    end
  end

  @doc """
  Creates a gRPC channel for connecting to LiveKit server.
  """
  def create_channel(host, port, opts \\ []) do
    endpoint = "#{host}:#{port}"
    Logger.debug("Attempting to connect to gRPC server at #{endpoint}")

    # LiveKit uses HTTP/2 over the same port as HTTP API
    # Try different configurations for LiveKit server
    configs_to_try = [
      # Try HTTP/2 cleartext (h2c) which LiveKit often uses
      [
        adapter: GRPC.Client.Adapters.Gun,
        adapter_opts: [protocols: [:h2c]]
      ],
      # Try with explicit HTTP scheme
      [
        adapter: GRPC.Client.Adapters.Gun,
        adapter_opts: [protocols: [:h2c]],
        scheme: "http"
      ],
      # Try with Mint adapter and h2c
      [
        adapter: GRPC.Client.Adapters.Mint,
        scheme: "http"
      ],
      # Try basic Gun adapter
      [
        adapter: GRPC.Client.Adapters.Gun
      ]
    ]

    # Merge user options with each config and try them
    configs_to_try = Enum.map(configs_to_try, &Keyword.merge(&1, opts))

    try_connect(endpoint, configs_to_try)
  end

  defp try_connect(endpoint, [config | rest]) do
    case GRPC.Stub.connect(endpoint, config) do
      {:ok, channel} ->
        Logger.debug("Successfully connected to gRPC server at #{endpoint}")
        {:ok, channel}

      {:error, reason} ->
        Logger.debug("Failed to connect with config #{inspect(config)}: #{inspect(reason)}")
        try_connect(endpoint, rest)
    end
  end

  defp try_connect(endpoint, []) do
    Logger.error("Failed to connect to gRPC server at #{endpoint} with all configurations")
    {:error, {:connection_failed, :all_configurations_failed}}
  end

  @doc """
  Creates authorization headers for gRPC requests using JWT token.
  """
  def auth_headers(token) when is_binary(token) do
    [{"authorization", "Bearer #{token}"}]
  end

  def auth_headers(_), do: []

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

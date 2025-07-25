defmodule Livekitex.EgressService do
  @moduledoc """
  LiveKit Egress Service client for recording and streaming functionality.

  This module provides a client for the LiveKit Egress service, allowing you to:
  - Start room composite recordings
  - Start track composite recordings
  - Start participant recordings
  - Start web recordings
  - Start track recordings
  - Update layouts and streams
  - List and stop egress sessions
  """

  require Logger
  alias Livekitex.{AccessToken, Grants, GrpcUtils}

  @default_host "localhost:7880"

  defstruct [:api_key, :api_secret, :host]

  @type t :: %__MODULE__{
          api_key: String.t(),
          api_secret: String.t(),
          host: String.t()
        }

  @doc """
  Creates a new EgressService client.

  ## Parameters

  - `api_key` - LiveKit API key
  - `api_secret` - LiveKit API secret
  - `host` - LiveKit server host (optional, defaults to localhost:7880)

  ## Examples

      iex> Livekitex.EgressService.new("api_key", "api_secret")
      %Livekitex.EgressService{api_key: "api_key", api_secret: "api_secret", host: "localhost:7880"}

      iex> Livekitex.EgressService.new("api_key", "api_secret", "livekit.example.com:443")
      %Livekitex.EgressService{api_key: "api_key", api_secret: "api_secret", host: "livekit.example.com:443"}
  """
  def new(api_key, api_secret, host \\ @default_host) do
    %__MODULE__{
      api_key: api_key,
      api_secret: api_secret,
      host: host
    }
  end

  @doc """
  Starts a room composite egress (recording the entire room).

  ## Parameters

  - `client` - EgressService client
  - `room_name` - Name of the room to record
  - `output` - Output configuration (file, stream, or list of outputs)
  - `opts` - Additional options

  ## Options

  - `:layout` - Layout template to use
  - `:audio_only` - Record audio only (default: false)
  - `:video_only` - Record video only (default: false)
  - `:custom_base_url` - Custom base URL for templates
  - `:preset` - Encoding preset
  - `:advanced` - Advanced encoding options

  ## Examples

      file_output = %{
        filepath: "recordings/{room_name}-{time}",
        s3: %{
          access_key: "key",
          secret: "secret",
          region: "us-west-2",
          bucket: "my-bucket"
        }
      }

      {:ok, egress_info} = Livekitex.EgressService.start_room_composite_egress(
        client,
        "my-room",
        file_output,
        layout: "grid"
      )
  """
  def start_room_composite_egress(client, room_name, output, opts \\ []) do
    request = %Livekit.RoomCompositeEgressRequest{
      room_name: room_name,
      layout: Keyword.get(opts, :layout),
      audio_only: Keyword.get(opts, :audio_only, false),
      video_only: Keyword.get(opts, :video_only, false),
      custom_base_url: Keyword.get(opts, :custom_base_url)
    }

    request = set_output(request, output)
    request = set_encoding_options(request, opts)

    with {:ok, channel} <- create_channel(client),
         {:ok, token} <- create_egress_token(client),
         headers <- GrpcUtils.auth_headers(token) do
      case Livekit.EgressService.Stub.start_room_composite_egress(channel, request, headers) do
        {:ok, response} ->
          Logger.info("Started room composite egress: #{response.egress_id}")
          {:ok, convert_egress_info(response)}

        {:error, error} ->
          Logger.error("Failed to start room composite egress: #{inspect(error)}")
          GrpcUtils.handle_grpc_response(error)
      end
    end
  end

  @doc """
  Starts a track composite egress (recording specific tracks).

  ## Parameters

  - `client` - EgressService client
  - `room_name` - Name of the room
  - `output` - Output configuration
  - `opts` - Additional options

  ## Options

  - `:audio_track_id` - ID of audio track to record
  - `:video_track_id` - ID of video track to record
  - `:preset` - Encoding preset
  - `:advanced` - Advanced encoding options
  """
  def start_track_composite_egress(client, room_name, output, opts \\ []) do
    request = %Livekit.TrackCompositeEgressRequest{
      room_name: room_name,
      audio_track_id: Keyword.get(opts, :audio_track_id),
      video_track_id: Keyword.get(opts, :video_track_id)
    }

    request = set_output(request, output)
    request = set_encoding_options(request, opts)

    with {:ok, channel} <- create_channel(client),
         {:ok, token} <- create_egress_token(client),
         headers <- GrpcUtils.auth_headers(token) do
      case Livekit.EgressService.Stub.start_track_composite_egress(channel, request, headers) do
        {:ok, response} ->
          Logger.info("Started track composite egress: #{response.egress_id}")
          {:ok, convert_egress_info(response)}

        {:error, error} ->
          Logger.error("Failed to start track composite egress: #{inspect(error)}")
          GrpcUtils.handle_grpc_response(error)
      end
    end
  end

  @doc """
  Starts a participant egress (recording a specific participant).

  ## Parameters

  - `client` - EgressService client
  - `room_name` - Name of the room
  - `identity` - Participant identity
  - `output` - Output configuration
  - `opts` - Additional options

  ## Options

  - `:screen_share` - Record screen share (default: false)
  - `:preset` - Encoding preset
  - `:advanced` - Advanced encoding options
  """
  def start_participant_egress(client, room_name, identity, output, opts \\ []) do
    request = %Livekit.ParticipantEgressRequest{
      room_name: room_name,
      identity: identity,
      screen_share: Keyword.get(opts, :screen_share, false)
    }

    request = set_output(request, output)
    request = set_encoding_options(request, opts)

    with {:ok, channel} <- create_channel(client),
         {:ok, token} <- create_egress_token(client),
         headers <- GrpcUtils.auth_headers(token) do
      case Livekit.EgressService.Stub.start_participant_egress(channel, request, headers) do
        {:ok, response} ->
          Logger.info("Started participant egress: #{response.egress_id}")
          {:ok, convert_egress_info(response)}

        {:error, error} ->
          Logger.error("Failed to start participant egress: #{inspect(error)}")
          GrpcUtils.handle_grpc_error(error)
      end
    end
  end

  @doc """
  Starts a web egress (recording a web page).

  ## Parameters

  - `client` - EgressService client
  - `url` - URL to record
  - `output` - Output configuration
  - `opts` - Additional options

  ## Options

  - `:audio_only` - Record audio only (default: false)
  - `:video_only` - Record video only (default: false)
  - `:await_start_signal` - Wait for start signal (default: false)
  - `:preset` - Encoding preset
  - `:advanced` - Advanced encoding options
  """
  def start_web_egress(client, url, output, opts \\ []) do
    request = %Livekit.WebEgressRequest{
      url: url,
      audio_only: Keyword.get(opts, :audio_only, false),
      video_only: Keyword.get(opts, :video_only, false),
      await_start_signal: Keyword.get(opts, :await_start_signal, false)
    }

    request = set_output(request, output)
    request = set_encoding_options(request, opts)

    with {:ok, channel} <- create_channel(client),
         {:ok, token} <- create_egress_token(client),
         headers <- GrpcUtils.auth_headers(token) do
      case Livekit.EgressService.Stub.start_web_egress(channel, request, headers) do
        {:ok, response} ->
          Logger.info("Started web egress: #{response.egress_id}")
          {:ok, convert_egress_info(response)}

        {:error, error} ->
          Logger.error("Failed to start web egress: #{inspect(error)}")
          GrpcUtils.handle_grpc_error(error)
      end
    end
  end

  @doc """
  Starts a track egress (recording a single track).

  ## Parameters

  - `client` - EgressService client
  - `room_name` - Name of the room
  - `track_id` - ID of the track to record
  - `output` - Output configuration (file path or websocket URL)

  ## Examples

      # Record to file
      {:ok, egress_info} = Livekitex.EgressService.start_track_egress(
        client,
        "my-room",
        "track_id",
        %{filepath: "track-{time}.webm"}
      )

      # Stream to websocket
      {:ok, egress_info} = Livekitex.EgressService.start_track_egress(
        client,
        "my-room",
        "track_id",
        "ws://localhost:8080/track"
      )
  """
  def start_track_egress(client, room_name, track_id, output) do
    request = %Livekit.TrackEgressRequest{
      room_name: room_name,
      track_id: track_id
    }

    request =
      cond do
        is_binary(output) ->
          request
          |> Map.put(:websocket_url, output)

        is_map(output) and Map.has_key?(output, :filepath) ->
          file_output = %Livekit.DirectFileOutput{
            filepath: output.filepath,
            disable_manifest: Map.get(output, :disable_manifest, false)
          }

          file_output = set_upload_config(file_output, output)

          request
          |> Map.put(:file, file_output)

        true ->
          request
      end

    with {:ok, channel} <- create_channel(client),
         {:ok, token} <- create_egress_token(client),
         headers <- GrpcUtils.auth_headers(token) do
      case Livekit.EgressService.Stub.start_track_egress(channel, request, headers) do
        {:ok, response} ->
          Logger.info("Started track egress: #{response.egress_id}")
          {:ok, convert_egress_info(response)}

        {:error, error} ->
          Logger.error("Failed to start track egress: #{inspect(error)}")
          GrpcUtils.handle_grpc_error(error)
      end
    end
  end

  @doc """
  Updates the layout of an active egress.

  ## Parameters

  - `client` - EgressService client
  - `egress_id` - ID of the egress to update
  - `layout` - New layout template
  """
  def update_layout(client, egress_id, layout) do
    request = %Livekit.UpdateLayoutRequest{
      egress_id: egress_id,
      layout: layout
    }

    with {:ok, channel} <- create_channel(client),
         {:ok, token} <- create_egress_token(client),
         headers <- GrpcUtils.auth_headers(token) do
      case Livekit.EgressService.Stub.update_layout(channel, request, headers) do
        {:ok, response} ->
          Logger.info("Updated layout for egress: #{egress_id}")
          {:ok, convert_egress_info(response)}

        {:error, error} ->
          Logger.error("Failed to update layout: #{inspect(error)}")
          GrpcUtils.handle_grpc_error(error)
      end
    end
  end

  @doc """
  Updates stream outputs for an active egress.

  ## Parameters

  - `client` - EgressService client
  - `egress_id` - ID of the egress to update
  - `opts` - Update options

  ## Options

  - `:add_output_urls` - List of URLs to add
  - `:remove_output_urls` - List of URLs to remove
  """
  def update_stream(client, egress_id, opts \\ []) do
    request = %Livekit.UpdateStreamRequest{
      egress_id: egress_id,
      add_output_urls: Keyword.get(opts, :add_output_urls, []),
      remove_output_urls: Keyword.get(opts, :remove_output_urls, [])
    }

    with {:ok, channel} <- create_channel(client),
         {:ok, token} <- create_egress_token(client),
         headers <- GrpcUtils.auth_headers(token) do
      case Livekit.EgressService.Stub.update_stream(channel, request, headers) do
        {:ok, response} ->
          Logger.info("Updated stream for egress: #{egress_id}")
          {:ok, convert_egress_info(response)}

        {:error, error} ->
          Logger.error("Failed to update stream: #{inspect(error)}")
          GrpcUtils.handle_grpc_error(error)
      end
    end
  end

  @doc """
  Lists egress sessions.

  ## Parameters

  - `client` - EgressService client
  - `opts` - List options

  ## Options

  - `:room_name` - Filter by room name
  - `:egress_id` - Filter by egress ID
  - `:active` - List only active egress sessions
  """
  def list_egress(client, opts \\ []) do
    request = %Livekit.ListEgressRequest{
      room_name: Keyword.get(opts, :room_name),
      egress_id: Keyword.get(opts, :egress_id),
      active: Keyword.get(opts, :active, false)
    }

    with {:ok, channel} <- create_channel(client),
         {:ok, token} <- create_egress_token(client),
         headers <- GrpcUtils.auth_headers(token) do
      case Livekit.EgressService.Stub.list_egress(channel, request, headers) do
        {:ok, response} ->
          egress_list = Enum.map(response.items, &convert_egress_info/1)
          {:ok, egress_list}

        {:error, error} ->
          Logger.error("Failed to list egress: #{inspect(error)}")
          GrpcUtils.handle_grpc_error(error)
      end
    end
  end

  @doc """
  Stops an egress session.

  ## Parameters

  - `client` - EgressService client
  - `egress_id` - ID of the egress to stop
  """
  def stop_egress(client, egress_id) do
    request = %Livekit.StopEgressRequest{egress_id: egress_id}

    with {:ok, channel} <- create_channel(client),
         {:ok, token} <- create_egress_token(client),
         headers <- GrpcUtils.auth_headers(token) do
      case Livekit.EgressService.Stub.stop_egress(channel, request, headers) do
        {:ok, response} ->
          Logger.info("Stopped egress: #{egress_id}")
          {:ok, convert_egress_info(response)}

        {:error, error} ->
          Logger.error("Failed to stop egress: #{inspect(error)}")
          GrpcUtils.handle_grpc_error(error)
      end
    end
  end

  # Private functions

  defp create_channel(client) do
    GrpcUtils.create_channel(client.host, 7880)
  end

  defp create_egress_token(client) do
    grant = %Grants.VideoGrant{room_record: true}

    case AccessToken.create(client.api_key, client.api_secret, identity: "egress")
         |> AccessToken.set_video_grant(grant)
         |> AccessToken.to_jwt() do
      {:ok, token, _claims} -> {:ok, token}
      {:error, reason} -> {:error, reason}
    end
  end

  defp set_output(request, output) when is_list(output) do
    Enum.reduce(output, request, &set_single_output(&2, &1))
  end

  defp set_output(request, output) do
    set_single_output(request, output)
  end

  defp set_single_output(request, %{file_type: _} = output) do
    file_output = create_encoded_file_output(output)
    %{request | file_outputs: [file_output]}
  end

  defp set_single_output(request, %{protocol: _} = output) do
    stream_output = create_stream_output(output)
    %{request | stream_outputs: [stream_output]}
  end

  defp set_single_output(request, %{filename_prefix: _} = output) do
    segment_output = create_segmented_file_output(output)
    %{request | segment_outputs: [segment_output]}
  end

  defp set_single_output(request, %{codec: _} = output) do
    image_output = create_image_output(output)
    %{request | image_outputs: [image_output]}
  end

  defp set_single_output(request, output) do
    # Default to encoded file output
    file_output = create_encoded_file_output(output)
    %{request | file_outputs: [file_output]}
  end

  defp create_encoded_file_output(output) do
    file_output = %Livekit.EncodedFileOutput{
      file_type: Map.get(output, :file_type, :DEFAULT_FILETYPE),
      filepath: Map.get(output, :filepath, "{room_name}-{time}"),
      disable_manifest: Map.get(output, :disable_manifest, false)
    }

    set_upload_config(file_output, output)
  end

  defp create_stream_output(output) do
    %Livekit.StreamOutput{
      protocol: Map.get(output, :protocol, :DEFAULT_PROTOCOL),
      urls: Map.get(output, :urls, [])
    }
  end

  defp create_segmented_file_output(output) do
    segment_output = %Livekit.SegmentedFileOutput{
      protocol: Map.get(output, :protocol, :DEFAULT_SEGMENTED_FILE_PROTOCOL),
      filename_prefix: Map.get(output, :filename_prefix, "{room_name}-{time}"),
      playlist_name: Map.get(output, :playlist_name),
      segment_duration: Map.get(output, :segment_duration),
      filename_suffix: Map.get(output, :filename_suffix),
      disable_manifest: Map.get(output, :disable_manifest, false)
    }

    set_upload_config(segment_output, output)
  end

  defp create_image_output(output) do
    image_output = %Livekit.ImageOutput{
      codec: Map.get(output, :codec, :IC_DEFAULT),
      width: Map.get(output, :width),
      height: Map.get(output, :height),
      filename_prefix: Map.get(output, :filename_prefix, "{room_name}-{time}"),
      filename_suffix: Map.get(output, :filename_suffix),
      image_interval: Map.get(output, :image_interval),
      disable_manifest: Map.get(output, :disable_manifest, false)
    }

    set_upload_config(image_output, output)
  end

  defp set_upload_config(output, config) do
    cond do
      Map.has_key?(config, :s3) ->
        s3_config = config.s3

        s3_upload = %Livekit.S3Upload{
          access_key: Map.get(s3_config, :access_key),
          secret: Map.get(s3_config, :secret),
          session_token: Map.get(s3_config, :session_token),
          region: Map.get(s3_config, :region),
          endpoint: Map.get(s3_config, :endpoint),
          bucket: Map.get(s3_config, :bucket),
          force_path_style: Map.get(s3_config, :force_path_style, false),
          metadata: Map.get(s3_config, :metadata, %{}),
          tagging: Map.get(s3_config, :tagging)
        }

        %{output | s3: s3_upload}

      Map.has_key?(config, :gcp) ->
        gcp_config = config.gcp

        gcp_upload = %Livekit.GCPUpload{
          credentials: Map.get(gcp_config, :credentials),
          bucket: Map.get(gcp_config, :bucket)
        }

        %{output | gcp: gcp_upload}

      Map.has_key?(config, :azure) ->
        azure_config = config.azure

        azure_upload = %Livekit.AzureBlobUpload{
          account_name: Map.get(azure_config, :account_name),
          account_key: Map.get(azure_config, :account_key),
          container_name: Map.get(azure_config, :container_name)
        }

        %{output | azure: azure_upload}

      Map.has_key?(config, :alioss) ->
        alioss_config = config.alioss

        alioss_upload = %Livekit.AliOSSUpload{
          access_key: Map.get(alioss_config, :access_key),
          secret: Map.get(alioss_config, :secret),
          region: Map.get(alioss_config, :region),
          endpoint: Map.get(alioss_config, :endpoint),
          bucket: Map.get(alioss_config, :bucket)
        }

        %{output | alioss: alioss_upload}

      true ->
        output
    end
  end

  defp set_encoding_options(request, opts) do
    cond do
      Keyword.has_key?(opts, :preset) ->
        %{request | preset: Keyword.get(opts, :preset)}

      Keyword.has_key?(opts, :advanced) ->
        advanced = Keyword.get(opts, :advanced)

        encoding_options = %Livekit.EncodingOptions{
          width: Map.get(advanced, :width, 1920),
          height: Map.get(advanced, :height, 1080),
          depth: Map.get(advanced, :depth, 24),
          framerate: Map.get(advanced, :framerate, 30),
          audio_codec: Map.get(advanced, :audio_codec, :OPUS),
          audio_bitrate: Map.get(advanced, :audio_bitrate, 44100),
          audio_quality: Map.get(advanced, :audio_quality),
          audio_frequency: Map.get(advanced, :audio_frequency, 44100),
          video_codec: Map.get(advanced, :video_codec, :H264_MAIN_CODEC),
          video_bitrate: Map.get(advanced, :video_bitrate, 4500),
          video_quality: Map.get(advanced, :video_quality),
          video_profile: Map.get(advanced, :video_profile, :H264_MAIN_PROFILE)
        }

        %{request | advanced: encoding_options}

      true ->
        request
    end
  end

  defp convert_egress_info(egress_info) do
    %{
      egress_id: egress_info.egress_id,
      room_id: egress_info.room_id,
      room_name: egress_info.room_name,
      status: egress_info.status,
      started_at: egress_info.started_at,
      ended_at: egress_info.ended_at,
      updated_at: egress_info.updated_at,
      details: egress_info.details,
      error: egress_info.error,
      stream_results: convert_stream_results(egress_info.stream_results),
      file_results: convert_file_results(egress_info.file_results),
      segment_results: convert_segment_results(egress_info.segment_results),
      image_results: convert_image_results(egress_info.image_results)
    }
  end

  defp convert_stream_results(results) when is_list(results) do
    Enum.map(results, fn result ->
      %{
        url: result.url,
        started_at: result.started_at,
        ended_at: result.ended_at,
        duration: result.duration,
        status: result.status,
        error: result.error
      }
    end)
  end

  defp convert_stream_results(_), do: []

  defp convert_file_results(results) when is_list(results) do
    Enum.map(results, fn result ->
      %{
        filename: result.filename,
        started_at: result.started_at,
        ended_at: result.ended_at,
        duration: result.duration,
        size: result.size,
        location: result.location
      }
    end)
  end

  defp convert_file_results(_), do: []

  defp convert_segment_results(results) when is_list(results) do
    Enum.map(results, fn result ->
      %{
        playlist: result.playlist,
        started_at: result.started_at,
        ended_at: result.ended_at,
        duration: result.duration,
        size: result.size,
        playlist_location: result.playlist_location,
        segment_count: result.segment_count
      }
    end)
  end

  defp convert_segment_results(_), do: []

  defp convert_image_results(results) when is_list(results) do
    Enum.map(results, fn result ->
      %{
        started_at: result.started_at,
        ended_at: result.ended_at,
        image_count: result.image_count
      }
    end)
  end

  defp convert_image_results(_), do: []
end

defmodule Livekitex.Webhook do
  @moduledoc """
  Webhook validation and processing for LiveKit events.

  This module provides functionality to validate and process webhooks sent by LiveKit server.
  It includes signature validation using HMAC-SHA256 and event parsing.
  """

  require Logger
  alias Livekitex.TokenVerifier

  @doc """
  Validates a webhook request and returns the parsed event.

  ## Parameters

  - `body` - The raw webhook body (binary)
  - `auth_header` - The Authorization header value
  - `api_secret` - The API secret for signature validation

  ## Returns

  - `{:ok, event}` - Successfully validated webhook with parsed event
  - `{:error, reason}` - Validation failed

  ## Examples

      iex> Livekitex.Webhook.validate_webhook(body, "Bearer token", "secret")
      {:ok, %{event: "room_started", room: %{...}}}

      iex> Livekitex.Webhook.validate_webhook(body, "invalid", "secret")
      {:error, :invalid_signature}
  """
  def validate_webhook(body, auth_header, api_secret)
      when is_binary(body) and is_binary(auth_header) and is_binary(api_secret) do
    with {:ok, token} <- extract_token(auth_header),
         verifier <- TokenVerifier.new("webhook", api_secret),
         {:ok, _claims} <- TokenVerifier.verify(verifier, token),
         {:ok, event} <- parse_webhook_event(body) do
      {:ok, event}
    else
      {:error, reason} -> {:error, reason}
    end
  end

  @doc """
  Validates a webhook using Plug.Conn for web frameworks.

  ## Parameters

  - `conn` - Plug.Conn struct
  - `api_secret` - The API secret for signature validation

  ## Returns

  - `{:ok, event}` - Successfully validated webhook with parsed event
  - `{:error, reason}` - Validation failed
  """
  def validate_webhook_conn(conn, api_secret) do
    with {:ok, body} <- read_body(conn),
         auth_header <- get_auth_header(conn) do
      validate_webhook(body, auth_header, api_secret)
    end
  end

  @doc """
  Parses a webhook event from JSON body.

  ## Parameters

  - `body` - JSON string containing the webhook event

  ## Returns

  - `{:ok, event}` - Successfully parsed event
  - `{:error, reason}` - Parsing failed
  """
  def parse_webhook_event(body) when is_binary(body) do
    case Jason.decode(body) do
      {:ok, json} ->
        event = %{
          event: Map.get(json, "event"),
          id: Map.get(json, "id"),
          created_at: Map.get(json, "createdAt"),
          room: parse_room(Map.get(json, "room")),
          participant: parse_participant(Map.get(json, "participant")),
          track: parse_track(Map.get(json, "track")),
          egress_info: parse_egress_info(Map.get(json, "egressInfo")),
          ingress_info: parse_ingress_info(Map.get(json, "ingressInfo")),
          num_dropped: Map.get(json, "numDropped", 0)
        }

        {:ok, event}

      {:error, reason} ->
        Logger.error("Failed to parse webhook JSON: #{inspect(reason)}")
        {:error, :invalid_json}
    end
  end

  @doc """
  Creates a Plug for webhook validation middleware.

  ## Parameters

  - `api_secret` - The API secret for signature validation
  - `opts` - Additional options (optional)

  ## Returns

  A Plug that validates webhooks and assigns the event to conn.assigns.webhook_event
  """
  def create_plug(api_secret, _opts \\ []) do
    fn conn, _opts ->
      case validate_webhook_conn(conn, api_secret) do
        {:ok, event} ->
          Logger.info("Webhook validated successfully: #{event.event}")
          Plug.Conn.assign(conn, :webhook_event, event)

        {:error, reason} ->
          Logger.warning("Webhook validation failed: #{inspect(reason)}")

          conn
          |> Plug.Conn.put_status(401)
          |> Plug.Conn.put_resp_content_type("application/json")
          |> Plug.Conn.send_resp(401, Jason.encode!(%{error: "Unauthorized"}))
          |> Plug.Conn.halt()
      end
    end
  end

  # Private functions

  defp extract_token("Bearer " <> token), do: {:ok, token}
  defp extract_token(_), do: {:error, :invalid_auth_header}

  defp read_body(conn) do
    case Plug.Conn.read_body(conn) do
      {:ok, body, _conn} -> {:ok, body}
      {:error, reason} -> {:error, reason}
    end
  end

  defp get_auth_header(conn) do
    case Plug.Conn.get_req_header(conn, "authorization") do
      [auth_header | _] -> auth_header
      [] -> ""
    end
  end

  defp parse_room(nil), do: nil

  defp parse_room(room_data) when is_map(room_data) do
    %{
      sid: Map.get(room_data, "sid"),
      name: Map.get(room_data, "name"),
      empty_timeout: Map.get(room_data, "emptyTimeout"),
      departure_timeout: Map.get(room_data, "departureTimeout"),
      max_participants: Map.get(room_data, "maxParticipants"),
      creation_time: Map.get(room_data, "creationTime"),
      metadata: Map.get(room_data, "metadata"),
      num_participants: Map.get(room_data, "numParticipants"),
      num_publishers: Map.get(room_data, "numPublishers"),
      active_recording: Map.get(room_data, "activeRecording", false)
    }
  end

  defp parse_participant(nil), do: nil

  defp parse_participant(participant_data) when is_map(participant_data) do
    %{
      sid: Map.get(participant_data, "sid"),
      identity: Map.get(participant_data, "identity"),
      state: Map.get(participant_data, "state"),
      metadata: Map.get(participant_data, "metadata"),
      joined_at: Map.get(participant_data, "joinedAt"),
      name: Map.get(participant_data, "name"),
      version: Map.get(participant_data, "version"),
      permission: parse_permission(Map.get(participant_data, "permission")),
      region: Map.get(participant_data, "region"),
      is_publisher: Map.get(participant_data, "isPublisher", false),
      kind: Map.get(participant_data, "kind"),
      attributes: Map.get(participant_data, "attributes", %{}),
      tracks: parse_tracks(Map.get(participant_data, "tracks", []))
    }
  end

  defp parse_permission(nil), do: nil

  defp parse_permission(permission_data) when is_map(permission_data) do
    %{
      can_subscribe: Map.get(permission_data, "canSubscribe", true),
      can_publish: Map.get(permission_data, "canPublish", true),
      can_publish_data: Map.get(permission_data, "canPublishData", true),
      can_publish_sources: Map.get(permission_data, "canPublishSources", []),
      hidden: Map.get(permission_data, "hidden", false),
      recorder: Map.get(permission_data, "recorder", false),
      can_update_metadata: Map.get(permission_data, "canUpdateMetadata", false),
      agent: Map.get(permission_data, "agent", false)
    }
  end

  defp parse_track(nil), do: nil

  defp parse_track(track_data) when is_map(track_data) do
    %{
      sid: Map.get(track_data, "sid"),
      type: Map.get(track_data, "type"),
      name: Map.get(track_data, "name"),
      muted: Map.get(track_data, "muted", false),
      width: Map.get(track_data, "width"),
      height: Map.get(track_data, "height"),
      simulcast: Map.get(track_data, "simulcast", false),
      disable_dtx: Map.get(track_data, "disableDtx", false),
      source: Map.get(track_data, "source"),
      layers: parse_video_layers(Map.get(track_data, "layers", [])),
      mime_type: Map.get(track_data, "mimeType"),
      mid: Map.get(track_data, "mid"),
      codecs: Map.get(track_data, "codecs", []),
      stereo: Map.get(track_data, "stereo", false),
      disable_red: Map.get(track_data, "disableRed", false)
    }
  end

  defp parse_tracks(tracks) when is_list(tracks) do
    Enum.map(tracks, &parse_track/1)
  end

  defp parse_video_layers(layers) when is_list(layers) do
    Enum.map(layers, fn layer ->
      %{
        quality: Map.get(layer, "quality"),
        width: Map.get(layer, "width"),
        height: Map.get(layer, "height"),
        bitrate: Map.get(layer, "bitrate"),
        ssrc: Map.get(layer, "ssrc")
      }
    end)
  end

  defp parse_egress_info(nil), do: nil

  defp parse_egress_info(egress_data) when is_map(egress_data) do
    %{
      egress_id: Map.get(egress_data, "egressId"),
      room_id: Map.get(egress_data, "roomId"),
      room_name: Map.get(egress_data, "roomName"),
      status: Map.get(egress_data, "status"),
      started_at: Map.get(egress_data, "startedAt"),
      ended_at: Map.get(egress_data, "endedAt"),
      updated_at: Map.get(egress_data, "updatedAt"),
      details: Map.get(egress_data, "details"),
      error: Map.get(egress_data, "error")
    }
  end

  defp parse_ingress_info(nil), do: nil

  defp parse_ingress_info(ingress_data) when is_map(ingress_data) do
    %{
      ingress_id: Map.get(ingress_data, "ingressId"),
      name: Map.get(ingress_data, "name"),
      stream_key: Map.get(ingress_data, "streamKey"),
      url: Map.get(ingress_data, "url"),
      input_type: Map.get(ingress_data, "inputType"),
      bypass_transcoding: Map.get(ingress_data, "bypassTranscoding", false),
      room_name: Map.get(ingress_data, "roomName"),
      participant_identity: Map.get(ingress_data, "participantIdentity"),
      participant_name: Map.get(ingress_data, "participantName"),
      reusable: Map.get(ingress_data, "reusable", false)
    }
  end
end

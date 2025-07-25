defmodule Livekitex do
  @moduledoc """
  LiveKit Elixir SDK - A comprehensive client library for LiveKit.

  LiveKit is an open-source WebRTC infrastructure for building real-time
  video and audio applications. This SDK provides a complete set of tools
  for integrating with LiveKit servers, including:

  - Room management and participant control
  - Access token generation and validation
  - Webhook processing and validation
  - Structured logging and telemetry

  ## Quick Start

      # Configure the SDK
      config :livekitex,
        api_key: "your_api_key",
        api_secret: "your_api_secret",
        host: "your_livekit_host"

      # Create a room service client
      client = Livekitex.room_service()

      # Create a room
      {:ok, room} = Livekitex.RoomService.create_room(client, "my-room")

      # Generate an access token
      token = Livekitex.access_token("participant_identity")
      |> Livekitex.AccessToken.add_grant(%Livekitex.Grants.VideoGrant{
        room_join: true,
        room: "my-room"
      })
      |> Livekitex.AccessToken.to_jwt()

  ## Configuration

  The SDK can be configured through multiple sources:

  1. Application configuration (config.exs)
  2. Environment variables
  3. Runtime configuration

  See `Livekitex.Config` for detailed configuration options.

  ## Services

  - `Livekitex.RoomService` - Room and participant management
  - `Livekitex.Webhook` - Webhook validation and processing
  - `Livekitex.AccessToken` - Token generation and validation
  """

  alias Livekitex.{Config, RoomService, AccessToken, Grants}

  @doc """
  Creates a room service client with current configuration.

  ## Examples

      client = Livekitex.room_service()
      {:ok, room} = Livekitex.RoomService.create_room(client, "my-room")
  """
  def room_service do
    config = Config.client_config()
    RoomService.create(config.api_key, config.api_secret, host: config.host)
  end

  @doc """
  Creates an access token for the given identity.

  ## Parameters

  - `identity` - Participant identity
  - `opts` - Token options (optional)

  ## Options

  - `:ttl` - Token time-to-live in seconds (default: 600)
  - `:name` - Participant name
  - `:metadata` - Additional metadata
  - `:attributes` - Additional attributes

  ## Examples

      token = Livekitex.access_token("user123")
      |> Livekitex.AccessToken.set_video_grant(%Livekitex.Grants.VideoGrant{
        room_join: true,
        room: "my-room"
      })
      |> Livekitex.AccessToken.to_jwt()
  """
  def access_token(identity, opts \\ []) do
    config = Config.get()

    AccessToken.create(config.api_key, config.api_secret,
      identity: identity,
      ttl: Keyword.get(opts, :ttl, 600),
      name: Keyword.get(opts, :name),
      metadata: Keyword.get(opts, :metadata),
      attributes: Keyword.get(opts, :attributes)
    )
  end

  @doc """
  Creates a room join token for the given identity and room.

  This is a convenience function that creates an access token with
  room join permissions.

  ## Parameters

  - `identity` - Participant identity
  - `room` - Room name
  - `opts` - Additional options

  ## Options

  - `:ttl` - Token time-to-live in seconds (default: 3600)
  - `:can_publish` - Can publish tracks (default: true)
  - `:can_subscribe` - Can subscribe to tracks (default: true)
  - `:can_publish_data` - Can publish data (default: true)
  - `:hidden` - Hidden participant (default: false)
  - `:recorder` - Recorder participant (default: false)
  - `:metadata` - Participant metadata

  ## Examples

      {:ok, token} = Livekitex.room_join_token("user123", "my-room")

      {:ok, token} = Livekitex.room_join_token("user123", "my-room",
        can_publish: false,
        metadata: %{"role" => "viewer"}
      )
  """
  def room_join_token(identity, room, opts \\ []) do
    video_grant = %Grants.VideoGrant{
      room_join: true,
      room: room,
      can_publish: Keyword.get(opts, :can_publish, true),
      can_subscribe: Keyword.get(opts, :can_subscribe, true),
      can_publish_data: Keyword.get(opts, :can_publish_data, true),
      hidden: Keyword.get(opts, :hidden, false),
      recorder: Keyword.get(opts, :recorder, false)
    }

    token =
      access_token(identity, opts)
      |> AccessToken.set_video_grant(video_grant)

    case AccessToken.to_jwt(token) do
      {:ok, jwt, _claims} -> {:ok, jwt}
      {:error, reason} -> {:error, reason}
    end
  end

  @doc """
  Creates an admin token with full permissions.

  This token can be used for administrative operations like
  creating rooms, managing participants, etc.

  ## Parameters

  - `opts` - Token options (optional)

  ## Options

  - `:ttl` - Token time-to-live in seconds (default: 3600)
  - `:room` - Specific room (optional, for room-specific admin)

  ## Examples

      {:ok, token} = Livekitex.admin_token()

      {:ok, token} = Livekitex.admin_token(room: "my-room", ttl: 7200)
  """
  def admin_token(opts \\ []) do
    video_grant = %Grants.VideoGrant{
      room_admin: true,
      room_list: true,
      room_record: true,
      room_create: true,
      room: Keyword.get(opts, :room)
    }

    token =
      access_token("admin", opts)
      |> AccessToken.set_video_grant(video_grant)

    case AccessToken.to_jwt(token) do
      {:ok, jwt, _claims} -> {:ok, jwt}
      {:error, reason} -> {:error, reason}
    end
  end

  @doc """
  Validates a webhook request.

  ## Parameters

  - `body` - Raw webhook body
  - `auth_header` - Authorization header
  - `api_secret` - API secret (optional, uses configured secret if not provided)

  ## Examples

      {:ok, event} = Livekitex.validate_webhook(body, auth_header)

      {:ok, event} = Livekitex.validate_webhook(body, auth_header, "custom_secret")
  """
  def validate_webhook(body, auth_header, api_secret \\ nil) do
    secret = api_secret || Config.get(:api_secret)
    Livekitex.Webhook.validate_webhook(body, auth_header, secret)
  end

  @doc """
  Starts the LiveKit SDK application.

  This sets up telemetry and other infrastructure.

  ## Examples

      Livekitex.start()
  """
  def start do
    # Setup telemetry
    Livekitex.Logger.setup_telemetry()
    :ok
  end

  @doc """
  Stops the LiveKit SDK application.

  ## Examples

      Livekitex.stop()
  """
  def stop do
    # Teardown telemetry
    Livekitex.Logger.teardown_telemetry()
    :ok
  end

  @doc """
  Gets the current SDK version.

  ## Examples

      iex> Livekitex.version()
      "0.1.0"
  """
  def version do
    Application.spec(:livekitex, :vsn) |> to_string()
  end

  @doc """
  Gets the current configuration.

  ## Examples

      config = Livekitex.config()
      # %{host: "localhost:7880", api_key: "...", ...}
  """
  def config do
    Config.get()
  end

  @doc """
  Updates configuration at runtime.

  ## Parameters

  - `key` - Configuration key
  - `value` - Configuration value

  ## Examples

      Livekitex.configure(:host, "production.livekit.io:443")
      Livekitex.configure(:use_tls, true)
  """
  def configure(key, value) do
    Config.put(key, value)
  end
end

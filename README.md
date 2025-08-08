# LiveKitEx

A comprehensive Elixir SDK for [LiveKit](https://livekit.io/), an open-source WebRTC infrastructure for building real-time video and audio applications. This library provides a complete set of tools for integrating with LiveKit servers using the modern Twirp RPC protocol over HTTP.

[![Hex Version](https://img.shields.io/hexpm/v/livekitex.svg)](https://hex.pm/packages/livekitex)
[![Documentation](https://img.shields.io/badge/docs-hexpm-blue.svg)](https://hexdocs.pm/livekitex)

## 🚀 Features

- **Room Management** - Create, delete, and list rooms
- **Participant Control** - Manage participants and their permissions
- **Access Token Generation** - JWT tokens for client authentication
- **Webhook Verification** - Verify and process LiveKit webhooks
- **Track Management** - Mute/unmute audio and video tracks
- **Modern HTTP-based Communication** - Uses Twirp over HTTP instead of gRPC
- **Comprehensive Error Handling** - Detailed error responses and logging
- **Production Ready** - Built with Tesla and Finch for reliable HTTP communication

## 📦 Installation

Add `livekitex` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
  {:livekitex, "~> 0.1.3"}
  ]
end
```

## ⚙️ Configuration

Configure your LiveKit server credentials in `config/config.exs`:

```elixir
import Config

config :livekitex,
  api_key: "your_api_key",
  api_secret: "your_api_secret",
  host: "localhost",  # Your LiveKit server host
  port: 7880          # LiveKit HTTP API port (default: 7880)

# Tesla HTTP client configuration
config :tesla, Tesla.Adapter.Finch, name: Livekitex.Finch
```

Or use environment variables:

```elixir
config :livekitex,
  api_key: System.get_env("LIVEKIT_API_KEY"),
  api_secret: System.get_env("LIVEKIT_API_SECRET"),
  host: System.get_env("LIVEKIT_HOST", "localhost"),
  port: String.to_integer(System.get_env("LIVEKIT_PORT", "7880"))
```

## 🚀 Quick Start

### Basic Room Management

```elixir
# Create a room service client
room_service = Livekitex.RoomService.create("your_api_key", "your_api_secret")

# Create a new room
{:ok, room} = Livekitex.RoomService.create_room(room_service, "my-room")
IO.inspect(room)

# List all rooms
{:ok, rooms} = Livekitex.RoomService.list_rooms(room_service)
IO.inspect(rooms)

# Delete a room
:ok = Livekitex.RoomService.delete_room(room_service, "my-room")
```

### Generate Access Tokens

```elixir
# Create an access token for a user
token = Livekitex.AccessToken.create(
  "your_api_key",
  "your_api_secret",
  identity: "user123",
  name: "John Doe"
)

# Set video permissions
video_grant = %Livekitex.Grants.VideoGrant{
  room_join: true,
  room: "my-room",
  can_publish: true,
  can_subscribe: true
}

token = Livekitex.AccessToken.set_video_grant(token, video_grant)

# Generate JWT
{:ok, jwt, _claims} = Livekitex.AccessToken.to_jwt(token)
IO.puts("Access token: #{jwt}")
```

## 📚 Comprehensive Usage Guide

### 1. Room Management

#### Creating Rooms with Options

```elixir
room_service = Livekitex.RoomService.create("api_key", "api_secret")

# Create a room with custom settings
options = [
  max_participants: 50,
  empty_timeout: 600,        # Auto-delete after 10 minutes of being empty
  departure_timeout: 30,     # Wait 30 seconds after last participant leaves
  metadata: "Conference Room A"
]

{:ok, room} = Livekitex.RoomService.create_room(room_service, "conference-room", options)

# Room details
IO.puts("Room created: #{room.name}")
IO.puts("Room SID: #{room.sid}")
IO.puts("Max participants: #{room.max_participants}")
IO.puts("Creation time: #{room.creation_time}")
```

#### Listing and Filtering Rooms

```elixir
# List all rooms
{:ok, all_rooms} = Livekitex.RoomService.list_rooms(room_service)

# Filter rooms by name
{:ok, filtered_rooms} = Livekitex.RoomService.list_rooms(
  room_service,
  names: ["room1", "room2", "room3"]
)

Enum.each(filtered_rooms, fn room ->
  IO.puts("Room: #{room.name} (#{room.num_participants} participants)")
end)
```

### 2. Participant Management

#### Listing Participants

```elixir
# List all participants in a room
{:ok, participants} = Livekitex.RoomService.list_participants(room_service, "my-room")

Enum.each(participants, fn participant ->
  IO.puts("Participant: #{participant.identity} (#{participant.name})")
  IO.puts("  State: #{participant.state}")
  IO.puts("  Joined at: #{participant.joined_at}")
  IO.puts("  Is publisher: #{participant.is_publisher}")
  IO.puts("  Tracks: #{length(participant.tracks)}")
end)
```

#### Removing Participants

```elixir
# Remove a participant from a room
:ok = Livekitex.RoomService.remove_participant(room_service, "my-room", "user123")
```

#### Managing Published Tracks

```elixir
# Mute a participant's audio track
{:ok, track} = Livekitex.RoomService.mute_published_track(
  room_service,
  "my-room",
  "user123",
  "track_sid_audio",
  true  # muted = true
)

# Unmute a participant's video track
{:ok, track} = Livekitex.RoomService.mute_published_track(
  room_service,
  "my-room",
  "user123",
  "track_sid_video",
  false  # muted = false
)

IO.puts("Track #{track.sid} mute status: #{track.muted}")
```

### 3. Access Token Generation

#### Basic User Token

```elixir
# Simple user token with room access
token = Livekitex.AccessToken.create(
  "api_key",
  "api_secret",
  identity: "user123",
  name: "John Doe",
  metadata: %{role: "presenter", department: "engineering"},
  ttl: 3600  # Token valid for 1 hour
)

video_grant = %Livekitex.Grants.VideoGrant{
  room_join: true,
  room: "my-room",
  can_publish: true,
  can_subscribe: true,
  can_publish_data: true
}

token = Livekitex.AccessToken.set_video_grant(token, video_grant)
{:ok, jwt, claims} = Livekitex.AccessToken.to_jwt(token)
```

#### Admin Token for Room Management

```elixir
# Create admin token for room management operations
admin_token = Livekitex.AccessToken.create(
  "api_key",
  "api_secret",
  identity: "admin"
)

admin_grant = %Livekitex.Grants.VideoGrant{
  room_admin: true,
  room_list: true,
  room_create: true,
  room_record: true
}

admin_token = Livekitex.AccessToken.set_video_grant(admin_token, admin_grant)
{:ok, admin_jwt, _} = Livekitex.AccessToken.to_jwt(admin_token)
```

#### Role-Based Tokens

```elixir
defmodule MyApp.TokenGenerator do
  alias Livekitex.{AccessToken, Grants}

  def generate_token(user_id, role, room_name) do
    token = AccessToken.create(
      Application.get_env(:livekitex, :api_key),
      Application.get_env(:livekitex, :api_secret),
      identity: user_id,
      name: get_user_name(user_id),
      ttl: 7200  # 2 hours
    )

    video_grant = case role do
      :host ->
        %Grants.VideoGrant{
          room_join: true,
          room: room_name,
          can_publish: true,
          can_subscribe: true,
          can_publish_data: true,
          can_update_metadata: true
        }

      :presenter ->
        %Grants.VideoGrant{
          room_join: true,
          room: room_name,
          can_publish: true,
          can_subscribe: true,
          can_publish_data: false
        }

      :viewer ->
        %Grants.VideoGrant{
          room_join: true,
          room: room_name,
          can_publish: false,
          can_subscribe: true,
          can_publish_data: false
        }

      :recorder ->
        %Grants.VideoGrant{
          room_join: true,
          room: room_name,
          can_publish: true,
          can_subscribe: true,
          hidden: true,
          recorder: true
        }
    end

    token
    |> AccessToken.set_video_grant(video_grant)
    |> AccessToken.to_jwt()
  end

  defp get_user_name(user_id) do
    # Fetch user name from your database
    "User #{user_id}"
  end
end

# Usage
{:ok, host_token, _} = MyApp.TokenGenerator.generate_token("host123", :host, "meeting-room")
{:ok, viewer_token, _} = MyApp.TokenGenerator.generate_token("viewer456", :viewer, "meeting-room")
```

### 4. Webhook Processing

#### Webhook Verification and Processing

```elixir
defmodule MyApp.WebhookController do
  use MyAppWeb, :controller
  alias Livekitex.Webhook

  def receive_webhook(conn, _params) do
    # Get the raw body and authorization header
    {:ok, raw_body, _conn} = Plug.Conn.read_body(conn)
    auth_header = get_req_header(conn, "authorization") |> List.first()

    case Webhook.validate_webhook(raw_body, auth_header, get_api_secret()) do
      {:ok, event} ->
        process_webhook_event(event)
        json(conn, %{status: "ok"})

      {:error, reason} ->
        Logger.error("Webhook validation failed: #{inspect(reason)}")
        conn
        |> put_status(400)
        |> json(%{error: "Invalid webhook"})
    end
  end

  defp process_webhook_event(%{event: event_type} = event) do
    case event_type do
      "room_started" ->
        Logger.info("Room started: #{event.room.name}")
        # Handle room started event

      "room_finished" ->
        Logger.info("Room finished: #{event.room.name}")
        # Handle room finished event

      "participant_joined" ->
        Logger.info("Participant joined: #{event.participant.identity}")
        # Handle participant joined event

      "participant_left" ->
        Logger.info("Participant left: #{event.participant.identity}")
        # Handle participant left event

      "track_published" ->
        Logger.info("Track published: #{event.track.sid}")
        # Handle track published event

      "track_unpublished" ->
        Logger.info("Track unpublished: #{event.track.sid}")
        # Handle track unpublished event

      _ ->
        Logger.info("Unhandled webhook event: #{event_type}")
    end
  end

  defp get_api_secret do
    Application.get_env(:livekitex, :api_secret)
  end
end
```

### 5. Advanced Usage Patterns

#### Connection Pool and Client Management

```elixir
defmodule MyApp.LiveKitManager do
  use GenServer
  alias Livekitex.RoomService

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def init(_opts) do
    # Create a persistent room service client
    room_service = RoomService.create(
      Application.get_env(:livekitex, :api_key),
      Application.get_env(:livekitex, :api_secret),
      host: Application.get_env(:livekitex, :host),
      port: Application.get_env(:livekitex, :port)
    )

    {:ok, %{room_service: room_service}}
  end

  def create_room(name, opts \\ []) do
    GenServer.call(__MODULE__, {:create_room, name, opts})
  end

  def list_rooms do
    GenServer.call(__MODULE__, :list_rooms)
  end

  def delete_room(name) do
    GenServer.call(__MODULE__, {:delete_room, name})
  end

  def handle_call({:create_room, name, opts}, _from, state) do
    result = RoomService.create_room(state.room_service, name, opts)
    {:reply, result, state}
  end

  def handle_call(:list_rooms, _from, state) do
    result = RoomService.list_rooms(state.room_service)
    {:reply, result, state}
  end

  def handle_call({:delete_room, name}, _from, state) do
    result = RoomService.delete_room(state.room_service, name)
    {:reply, result, state}
  end
end

# Add to your application supervision tree
children = [
  MyApp.LiveKitManager
]
```

#### Error Handling and Retry Logic

```elixir
defmodule MyApp.RoomManager do
  alias Livekitex.RoomService
  require Logger

  def create_room_with_retry(room_service, name, opts \\ [], max_retries \\ 3) do
    do_create_room_with_retry(room_service, name, opts, max_retries, 0)
  end

  defp do_create_room_with_retry(room_service, name, opts, max_retries, attempt) do
    case RoomService.create_room(room_service, name, opts) do
      {:ok, room} ->
        {:ok, room}

      {:error, {:twirp_error, :econnrefused}} when attempt < max_retries ->
        Logger.warn("Connection refused, retrying in #{backoff_delay(attempt)}ms")
        Process.sleep(backoff_delay(attempt))
        do_create_room_with_retry(room_service, name, opts, max_retries, attempt + 1)

      {:error, {:unavailable, _}} when attempt < max_retries ->
        Logger.warn("Server unavailable, retrying in #{backoff_delay(attempt)}ms")
        Process.sleep(backoff_delay(attempt))
        do_create_room_with_retry(room_service, name, opts, max_retries, attempt + 1)

      {:error, reason} ->
        Logger.error("Failed to create room after #{attempt + 1} attempts: #{inspect(reason)}")
        {:error, reason}
    end
  end

  defp backoff_delay(attempt) do
    # Exponential backoff: 1s, 2s, 4s
    :math.pow(2, attempt) * 1000 |> round()
  end
end
```

### 6. Real-World Integration Examples

#### Phoenix LiveView Integration

```elixir
defmodule MyAppWeb.RoomLive do
  use MyAppWeb, :live_view
  alias MyApp.{TokenGenerator, LiveKitManager}

  @impl true
  def mount(%{"room_id" => room_id}, %{"user_id" => user_id}, socket) do
    # Ensure room exists
    case LiveKitManager.create_room(room_id) do
      {:ok, _room} ->
        # Generate access token for the user
        {:ok, token, _} = TokenGenerator.generate_token(user_id, :presenter, room_id)

        socket =
          socket
          |> assign(:room_id, room_id)
          |> assign(:user_id, user_id)
          |> assign(:access_token, token)
          |> assign(:connected, false)

        {:ok, socket}

      {:error, reason} ->
        {:error, "Failed to create room: #{inspect(reason)}"}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div id="livekit-room" class="w-full h-screen">
      <div class="p-4 bg-gray-100">
        <h1 class="text-2xl font-bold">Room: <%= @room_id %></h1>
        <p>User: <%= @user_id %></p>
      </div>

      <div id="video-container" class="flex-1" phx-hook="LiveKitRoom"
           data-room-id={@room_id} data-access-token={@access_token}>
        <!-- LiveKit will render video elements here -->
      </div>
    </div>
    """
  end
end
```

#### Background Job for Room Cleanup

```elixir
defmodule MyApp.Workers.RoomCleanup do
  use Oban.Worker, queue: :default, max_attempts: 3
  alias MyApp.LiveKitManager
  require Logger

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"action" => "cleanup_empty_rooms"}}) do
    case LiveKitManager.list_rooms() do
      {:ok, rooms} ->
        empty_rooms = Enum.filter(rooms, fn room -> room.num_participants == 0 end)

        Enum.each(empty_rooms, fn room ->
          case LiveKitManager.delete_room(room.name) do
            :ok ->
              Logger.info("Cleaned up empty room: #{room.name}")
            {:error, reason} ->
              Logger.error("Failed to cleanup room #{room.name}: #{inspect(reason)}")
          end
        end)

        {:ok, "Cleaned up #{length(empty_rooms)} empty rooms"}

      {:error, reason} ->
        Logger.error("Failed to list rooms for cleanup: #{inspect(reason)}")
        {:error, reason}
    end
  end

  # Schedule cleanup job every hour
  def schedule_cleanup do
    %{action: "cleanup_empty_rooms"}
    |> __MODULE__.new(schedule_in: 3600)
    |> Oban.insert()
  end
end
```

## 🔧 Configuration Options

### Room Service Configuration

```elixir
# Create room service with custom options
room_service = Livekitex.RoomService.create(
  "api_key",
  "api_secret",
  host: "livekit.example.com",
  port: 443  # Use 443 for HTTPS
)
```

### Tesla HTTP Client Configuration

```elixir
# In config/config.exs
config :tesla,
  adapter: {Tesla.Adapter.Finch, name: Livekitex.Finch},
  # Optional: Configure request timeout
  timeout: 30_000  # 30 seconds
```

## 📊 Error Handling

LiveKitEx provides comprehensive error handling for various scenarios:

```elixir
case Livekitex.RoomService.create_room(room_service, "test-room") do
  {:ok, room} ->
    # Success
    IO.puts("Room created: #{room.name}")

  {:error, {:already_exists, message}} ->
    # Room already exists
    IO.puts("Room already exists: #{message}")

  {:error, {:unauthenticated, message}} ->
    # Invalid API credentials
    IO.puts("Authentication failed: #{message}")

  {:error, {:not_found, message}} ->
    # Resource not found
    IO.puts("Not found: #{message}")

  {:error, {:twirp_error, reason}} ->
    # Connection or communication error
    IO.puts("Connection error: #{inspect(reason)}")

  {:error, reason} ->
    # Other errors
    IO.puts("Error: #{inspect(reason)}")
end
```

## 🧪 Testing

Run the test suite:

```bash
# Run all tests
mix test

# Run tests with coverage
mix test --cover

# Run specific test file
mix test test/livekitex/room_service_test.exs
```

The test suite includes integration tests that can run against a live LiveKit server. To run integration tests:

1. Start a LiveKit server in development mode:
   ```bash
   livekit-server --dev
   ```

2. Run the tests:
   ```bash
   mix test
   ```

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the Apache 2.0 License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- [LiveKit](https://livekit.io/) for the excellent WebRTC infrastructure
- [Twirp](https://github.com/keathley/twirp-elixir) for the Elixir Twirp implementation
- [Tesla](https://github.com/elixir-tesla/tesla) for the HTTP client
- [Finch](https://github.com/sneako/finch) for HTTP connection pooling

## 📚 Additional Resources

- [LiveKit Documentation](https://docs.livekit.io/)
- [LiveKit Client SDKs](https://docs.livekit.io/guides/client-sdk-reference/)
- [Twirp Protocol](https://twitchtv.github.io/twirp/docs/intro.html)
- [HexDocs](https://hexdocs.pm/livekitex)
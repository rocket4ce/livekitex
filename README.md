# Livekitex

An Elixir client for LiveKit, providing tools for interacting with LiveKit servers,
including access token generation, room management, and webhook verification.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `livekitex` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:livekitex, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/livekitex>.

## Quick Start

This section provides a quick guide to generating LiveKit access tokens.

First, ensure you have your LiveKit API Key and API Secret. It's recommended to set these as environment variables:

```bash
export LIVEKIT_API_KEY="YOUR_API_KEY"
export LIVEKIT_API_SECRET="YOUR_API_SECRET"
```

Now, you can generate an access token in your Elixir application:

```elixir
# In your iex session or application code

# 1. Create an AccessToken
#    Replace "user_identity" with a unique identifier for your user.
#    You can also pass options like `name`, `metadata`, `attributes`, and `ttl`.
token = Livekitex.AccessToken.create(
  System.get_env("LIVEKIT_API_KEY"),
  System.get_env("LIVEKIT_API_SECRET"),
  identity: "user_identity"
)

# 2. Set a VideoGrant for the token
#    This grant allows the user to join a room and publish audio/video.
#    Customize permissions as needed.
video_grant = Livekitex.Grants.VideoGrant.new(
  room_join: true,
  can_publish: true,
  room: "my_room" # Optional: restrict token to a specific room
)

token = Livekitex.AccessToken.set_video_grant(token, video_grant)

# 3. Generate the JWT
#    This JWT can be used by LiveKit clients to connect to your LiveKit server.
{:ok, jwt, _claims} = Livekitex.AccessToken.to_jwt(token)

IO.puts "Generated JWT: " <> jwt
```

## Cookbook

This cookbook provides practical examples for common LiveKit use cases with Livekitex.

### 1. Generating Access Tokens for Different Roles

LiveKit access tokens are used to authenticate users connecting to your LiveKit server. Different roles require different permissions, which are managed through `VideoGrant` and `SipGrant`.

### 1.1. Publisher Token (can publish and subscribe)

A publisher token allows a user to join a room, publish audio/video tracks, and subscribe to other participants' tracks.

```elixir
# Assuming LIVEKIT_API_KEY and LIVEKIT_API_SECRET are set as environment variables

identity = "publisher_user_123"
room_name = "my_conference_room"

token = Livekitex.AccessToken.create(
  System.get_env("LIVEKIT_API_KEY"),
  System.get_env("LIVEKIT_API_SECRET"),
  identity: identity
)

video_grant = Livekitex.Grants.VideoGrant.new(
  room_join: true,
  room: room_name,
  can_publish: true,
  can_subscribe: true
)

token = Livekitex.AccessToken.set_video_grant(token, video_grant)

{:ok, jwt, _claims} = Livekitex.AccessToken.to_jwt(token)
IO.puts "Publisher JWT: " <> jwt
```

### 1.2. Viewer Token (can only subscribe)

A viewer token allows a user to join a room and subscribe to tracks, but not publish their own.

```elixir
# Assuming LIVEKIT_API_KEY and LIVEKIT_API_SECRET are set as environment variables

identity = "viewer_user_456"
room_name = "my_conference_room"

token = Livekitex.AccessToken.create(
  System.get_env("LIVEKIT_API_KEY"),
  System.get_env("LIVEKIT_API_SECRET"),
  identity: identity
)

video_grant = Livekitex.Grants.VideoGrant.new(
  room_join: true,
  room: room_name,
  can_publish: false, # Important: set to false for viewers
  can_subscribe: true
)

token = Livekitex.AccessToken.set_video_grant(token, video_grant)

{:ok, jwt, _claims} = Livekitex.AccessToken.to_jwt(token)
IO.puts "Viewer JWT: " <> jwt
```

### 1.3. Recorder Token (hidden, can publish and subscribe)

A recorder token is typically used for automated recording bots. The `hidden: true` option ensures the participant does not appear in the participant list for other users.

```elixir
# Assuming LIVEKIT_API_KEY and LIVEKIT_API_SECRET are set as environment variables

identity = "recorder_bot_789"
room_name = "my_conference_room"

token = Livekitex.AccessToken.create(
  System.get_env("LIVEKIT_API_KEY"),
  System.get_env("LIVEKIT_API_SECRET"),
  identity: identity
)

video_grant = Livekitex.Grants.VideoGrant.new(
  room_join: true,
  room: room_name,
  can_publish: true,
  can_subscribe: true,
  hidden: true, # Important: hide the recorder from participant list
  recorder: true # Indicate this is a recorder
)

token = Livekitex.AccessToken.set_video_grant(token, video_grant)

{:ok, jwt, _claims} = Livekitex.AccessToken.to_jwt(token)
IO.puts "Recorder JWT: " <> jwt
```

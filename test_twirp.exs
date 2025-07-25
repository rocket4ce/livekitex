#!/usr/bin/env elixir

# Test script for the refactored Twirp client
Mix.install([
  {:livekitex, path: "."}
])

IO.puts("Testing Livekitex with Twirp...")

# Create room service client
room_service = Livekitex.RoomService.create("devkey", "secret")
IO.inspect(room_service, label: "Room Service")

# Test list_rooms (should fail gracefully if server is not configured for Twirp)
case Livekitex.RoomService.list_rooms(room_service) do
  {:ok, rooms} ->
    IO.puts("✓ Successfully listed rooms!")
    IO.inspect(rooms, label: "Rooms")

  {:error, reason} ->
    IO.puts("✗ Error listing rooms (expected if server doesn't support Twirp):")
    IO.inspect(reason, label: "Error")
end

IO.puts("Test completed!")
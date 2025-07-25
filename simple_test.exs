IO.puts("Testing Livekitex with Twirp...")

# Create room service client
room_service = Livekitex.RoomService.create("devkey", "secret")
IO.inspect(room_service, label: "Room Service")

# Test list_rooms
case Livekitex.RoomService.list_rooms(room_service) do
  {:ok, rooms} ->
    IO.puts("✓ Successfully listed rooms!")
    IO.inspect(rooms, label: "Rooms")

  {:error, reason} ->
    IO.puts("✗ Error listing rooms:")
    IO.inspect(reason, label: "Error")
end
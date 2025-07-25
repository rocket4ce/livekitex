IO.puts("Testing Livekitex Room Operations with Twirp...")

# Create room service client
room_service = Livekitex.RoomService.create("devkey", "secret")
IO.puts("✓ Created room service client")

# Test creating a room
case Livekitex.RoomService.create_room(room_service, "test-room-twirp") do
  {:ok, room} ->
    IO.puts("✓ Successfully created room!")
    IO.inspect(room, label: "Created Room")
    
    # List rooms to see our created room
    case Livekitex.RoomService.list_rooms(room_service) do
      {:ok, rooms} ->
        IO.puts("✓ Successfully listed rooms!")
        IO.inspect(rooms, label: "All Rooms")
        
        # Delete the room
        case Livekitex.RoomService.delete_room(room_service, "test-room-twirp") do
          :ok ->
            IO.puts("✓ Successfully deleted room!")
          {:error, reason} ->
            IO.puts("✗ Error deleting room:")
            IO.inspect(reason, label: "Delete Error")
        end
        
      {:error, reason} ->
        IO.puts("✗ Error listing rooms:")
        IO.inspect(reason, label: "List Error")
    end
    
  {:error, reason} ->
    IO.puts("✗ Error creating room:")
    IO.inspect(reason, label: "Create Error")
end

IO.puts("\nTest completed!")
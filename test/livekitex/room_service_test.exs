defmodule Livekitex.RoomServiceTest do
  use ExUnit.Case, async: false
  import Mox

  alias Livekitex.RoomService
  alias Livekit.Room
  alias Livekit.TrackInfo

  setup :verify_on_exit!

  setup do
    # Set up default stubs that can be overridden by individual tests
    Livekitex.RoomServiceMock
    |> stub(:create_room, fn _room_service, _name, _options ->
      {:ok, %Room{name: "mock-room", sid: "mock-sid"}}
    end)
    |> stub(:delete_room, fn _room_service, _room_name ->
      :ok
    end)
    |> stub(:list_rooms, fn _room_service, _options ->
      {:ok, [%Room{name: "mock-room-1", sid: "mock-sid-1"}]}
    end)
    |> stub(:list_participants, fn _room_service, _room_name ->
      {:ok, []}
    end)
    |> stub(:remove_participant, fn _room_service, _room_name, _identity ->
      :ok
    end)
    |> stub(:mute_published_track, fn _room_service, _room_name, _identity, _track_sid, _muted ->
      {:ok, %TrackInfo{}}
    end)

    room_service = RoomService.create("devkey", "secret", host: "localhost", port: 7881)
    {:ok, room_service: room_service}
  end

  describe "create_room/3" do
    test "creates a room successfully", %{room_service: room_service} do
      room_name = "test-room-#{System.unique_integer([:positive])}"

      assert {:ok, room} = RoomService.create_room(room_service, room_name)
      assert room.name == "mock-room"
      assert room.sid == "mock-sid"
    end

    test "creates a room with options", %{room_service: room_service} do
      room_name = "test-room-with-options-#{System.unique_integer([:positive])}"

      options = [
        max_participants: 10,
        empty_timeout: 300,
        metadata: "test metadata"
      ]

      assert {:ok, room} = RoomService.create_room(room_service, room_name, options)
      assert room.name == "mock-room"
      # Mocked response doesn't reflect options
      assert room.max_participants == 0
      # Mocked response doesn't reflect options
      assert room.empty_timeout == 0
      # Mocked response doesn't reflect options
      assert room.metadata == ""
    end

    test "returns error for duplicate room name", %{room_service: room_service} do
      room_name = "duplicate-room-#{System.unique_integer([:positive])}"

      Mox.expect(Livekitex.RoomServiceMock, :create_room, fn _room_service,
                                                             ^room_name,
                                                             _options ->
        {:error, {:already_exists, "room already exists"}}
      end)

      assert {:error, {:already_exists, _message}} =
               RoomService.create_room(room_service, room_name)
    end
  end

  describe "list_rooms/2" do
    test "lists all rooms", %{room_service: room_service} do
      assert {:ok, rooms} = RoomService.list_rooms(room_service)
      assert length(rooms) == 1
      assert hd(rooms).name == "mock-room-1"
    end

    test "filters rooms by name", %{room_service: room_service} do
      Mox.expect(Livekitex.RoomServiceMock, :list_rooms, fn _room_service, options ->
        if options[:names] == ["filter-test-room-1"] do
          {:ok, [%Room{name: "filter-test-room-1", sid: "mock-sid-filtered"}]}
        else
          {:ok, []}
        end
      end)

      assert {:ok, rooms} = RoomService.list_rooms(room_service, names: ["filter-test-room-1"])
      assert length(rooms) == 1
      assert hd(rooms).name == "filter-test-room-1"
    end
  end

  describe "delete_room/2" do
    test "deletes a room successfully", %{room_service: room_service} do
      room_name = "delete-test-room-#{System.unique_integer([:positive])}"
      assert :ok = RoomService.delete_room(room_service, room_name)
    end

    test "returns error for non-existent room", %{room_service: room_service} do
      non_existent_room = "non-existent-room-#{System.unique_integer([:positive])}"

      Mox.expect(Livekitex.RoomServiceMock, :delete_room, fn _room_service, ^non_existent_room ->
        {:error, {:not_found, "room not found"}}
      end)

      assert {:error, {:not_found, _message}} =
               RoomService.delete_room(room_service, non_existent_room)
    end
  end

  describe "list_participants/2" do
    test "lists participants in empty room", %{room_service: room_service} do
      room_name = "participants-test-room-#{System.unique_integer([:positive])}"
      assert {:ok, participants} = RoomService.list_participants(room_service, room_name)
      assert participants == []
    end

    test "returns error for non-existent room", %{room_service: room_service} do
      non_existent_room = "non-existent-room-#{System.unique_integer([:positive])}"

      Mox.expect(Livekitex.RoomServiceMock, :list_participants, fn _room_service,
                                                                   ^non_existent_room ->
        {:error, {:not_found, "room not found"}}
      end)

      assert {:error, {:not_found, _message}} =
               RoomService.list_participants(room_service, non_existent_room)
    end
  end

  describe "remove_participant/3" do
    test "returns error for non-existent participant", %{room_service: room_service} do
      room_name = "remove-participant-test-#{System.unique_integer([:positive])}"

      Mox.expect(Livekitex.RoomServiceMock, :remove_participant, fn _room_service,
                                                                    ^room_name,
                                                                    "non-existent-user" ->
        {:error, {:not_found, "participant not found"}}
      end)

      assert {:error, {:not_found, _message}} =
               RoomService.remove_participant(room_service, room_name, "non-existent-user")
    end
  end

  describe "mute_published_track/5" do
    test "returns error for non-existent track", %{room_service: room_service} do
      room_name = "mute-track-test-#{System.unique_integer([:positive])}"

      Mox.expect(Livekitex.RoomServiceMock, :mute_published_track, fn _room_service,
                                                                      ^room_name,
                                                                      "user",
                                                                      "track_sid",
                                                                      true ->
        {:error, {:not_found, "track not found"}}
      end)

      assert {:error, {:not_found, _message}} =
               RoomService.mute_published_track(
                 room_service,
                 room_name,
                 "user",
                 "track_sid",
                 true
               )
    end
  end

  describe "error handling" do
    test "handles connection errors gracefully" do
      Mox.expect(Livekitex.RoomServiceMock, :list_rooms, fn _room_service, _options ->
        {:error, {:connection_failed, "connection refused"}}
      end)

      room_service =
        Livekitex.RoomService.create("devkey", "secret", host: "localhost", port: 9999)

      assert {:error, {:connection_failed, _reason}} = RoomService.list_rooms(room_service)
    end

    test "handles authentication errors" do
      Mox.expect(Livekitex.RoomServiceMock, :list_rooms, fn _room_service, _options ->
        {:error, {:unauthenticated, "authentication failed"}}
      end)

      room_service =
        Livekitex.RoomService.create("invalid_key", "invalid_secret",
          host: "localhost",
          port: 7880
        )

      assert {:error, {:unauthenticated, _message}} = RoomService.list_rooms(room_service)
    end
  end
end

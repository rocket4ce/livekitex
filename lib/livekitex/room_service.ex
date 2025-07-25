defmodule Livekitex.RoomService do
  @moduledoc """
  Provides functionality to interact with the LiveKit RoomService API.
  """

  alias Livekitex.AccessToken
  alias Livekitex.Room

  defstruct api_key: nil,
            api_secret: nil,
            host: "localhost",
            port: 7880

  @type t :: %__MODULE__{
          api_key: String.t(),
          api_secret: String.t(),
          host: String.t(),
          port: integer()
        }

  @doc """
  Creates a new RoomService client.

  ## Parameters

    - `api_key`: The API key for your LiveKit project.
    - `api_secret`: The API secret for your LiveKit project.
    - `options`: A keyword list of options.
      - `host`: The host of the LiveKit server. Defaults to "localhost".
      - `port`: The port of the LiveKit server. Defaults to 7880.

  ## Examples

      iex> Livekitex.RoomService.create("api_key", "api_secret")
      %Livekitex.RoomService{
        api_key: "api_key",
        api_secret: "api_secret",
        host: "localhost",
        port: 7880
      }
  """
  def create(api_key, api_secret, options \\ []) do
    %__MODULE__{
      api_key: api_key,
      api_secret: api_secret,
      host: Keyword.get(options, :host, "localhost"),
      port: Keyword.get(options, :port, 7880)
    }
  end

  @doc """
  Creates a new room.

  ## Parameters

    - `room_service`: The RoomService client.
    - `name`: The name of the room.
    - `options`: A keyword list of options.

  ## Examples

      iex> room_service = Livekitex.RoomService.create("devkey", "secret")
      iex> Livekitex.RoomService.create_room(room_service, "test-room")
      {:ok, %Livekitex.Room{}}
  """
  def create_room(%__MODULE__{} = room_service, name, options \\ []) do
    # TODO: Implement gRPC call to create room
    {:ok, %Room{name: name}}
  end

  @doc """
  Deletes a room.

  ## Parameters

    - `room_service`: The RoomService client.
    - `room_name`: The name of the room to delete.

  ## Examples

      iex> room_service = Livekitex.RoomService.create("devkey", "secret")
      iex> Livekitex.RoomService.delete_room(room_service, "test-room")
      :ok
  """
  def delete_room(%__MODULE__{} = room_service, room_name) do
    # TODO: Implement gRPC call to delete room
    :ok
  end

  @doc """
  Lists all rooms.

  ## Parameters

    - `room_service`: The RoomService client.

  ## Examples

      iex> room_service = Livekitex.RoomService.create("devkey", "secret")
      iex> Livekitex.RoomService.list_rooms(room_service)
      {:ok, []}
  """
  def list_rooms(%__MODULE__{} = room_service) do
    # TODO: Implement gRPC call to list rooms
    {:ok, []}
  end
end

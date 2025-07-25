defmodule Livekitex.RoomServiceBehaviour do
  @moduledoc """
  Behaviour for Livekitex.RoomService.
  """

  @callback create(api_key :: String.t(), api_secret :: String.t(), options :: Keyword.t()) ::
              Livekitex.RoomService.t()
  @callback create_room(
              room_service :: Livekitex.RoomService.t(),
              name :: String.t(),
              options :: Keyword.t()
            ) :: {:ok, Livekitex.Room.t()} | {:error, any()}
  @callback delete_room(room_service :: Livekitex.RoomService.t(), room_name :: String.t()) ::
              :ok | {:error, any()}
  @callback list_rooms(room_service :: Livekitex.RoomService.t(), options :: Keyword.t()) ::
              {:ok, list(Livekitex.Room.t())} | {:error, any()}
  @callback list_participants(room_service :: Livekitex.RoomService.t(), room_name :: String.t()) ::
              {:ok, list(Livekitex.Participant.t())} | {:error, any()}
  @callback remove_participant(
              room_service :: Livekitex.RoomService.t(),
              room_name :: String.t(),
              identity :: String.t()
            ) :: :ok | {:error, any()}
  @callback mute_published_track(
              room_service :: Livekitex.RoomService.t(),
              room_name :: String.t(),
              identity :: String.t(),
              track_sid :: String.t(),
              muted :: boolean()
            ) :: {:ok, Livekitex.Track.t()} | {:error, any()}
end

defmodule Livekitex.RoomServiceTwirp do
  @moduledoc false
  use Twirp.Service

  package("livekit")
  service("RoomService")

  rpc(:CreateRoom, Livekit.CreateRoomRequest, Livekit.Room, :create_room)
  rpc(:ListRooms, Livekit.ListRoomsRequest, Livekit.ListRoomsResponse, :list_rooms)
  rpc(:DeleteRoom, Livekit.DeleteRoomRequest, Livekit.DeleteRoomResponse, :delete_room)

  rpc(
    :ListParticipants,
    Livekit.ListParticipantsRequest,
    Livekit.ListParticipantsResponse,
    :list_participants
  )

  rpc(
    :RemoveParticipant,
    Livekit.RoomParticipantIdentity,
    Livekit.RemoveParticipantResponse,
    :remove_participant
  )

  rpc(
    :MutePublishedTrack,
    Livekit.MuteRoomTrackRequest,
    Livekit.MuteRoomTrackResponse,
    :mute_published_track
  )
end

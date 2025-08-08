defmodule Livekitex.EgressServiceBehaviour do
  @moduledoc """
  Behaviour for Livekitex.EgressService.
  """

  alias Livekit.{
    EgressInfo,
    ListEgressResponse,
    RoomCompositeEgressRequest,
    TrackCompositeEgressRequest,
    TrackEgressRequest,
    WebEgressRequest,
    ParticipantEgressRequest,
    UpdateLayoutRequest,
    UpdateStreamRequest,
    ListEgressRequest,
    StopEgressRequest
  }

  @callback start_room_composite_egress(
              egress_service :: Livekitex.EgressService.t(),
              request :: RoomCompositeEgressRequest.t()
            ) :: {:ok, EgressInfo.t()} | {:error, any()}

  @callback start_track_composite_egress(
              egress_service :: Livekitex.EgressService.t(),
              request :: TrackCompositeEgressRequest.t()
            ) :: {:ok, EgressInfo.t()} | {:error, any()}

  @callback start_track_egress(
              egress_service :: Livekitex.EgressService.t(),
              request :: TrackEgressRequest.t()
            ) :: {:ok, EgressInfo.t()} | {:error, any()}

  @callback start_web_egress(
              egress_service :: Livekitex.EgressService.t(),
              request :: WebEgressRequest.t()
            ) :: {:ok, EgressInfo.t()} | {:error, any()}

  @callback start_participant_egress(
              egress_service :: Livekitex.EgressService.t(),
              request :: ParticipantEgressRequest.t()
            ) :: {:ok, EgressInfo.t()} | {:error, any()}

  @callback update_layout(
              egress_service :: Livekitex.EgressService.t(),
              request :: UpdateLayoutRequest.t()
            ) :: {:ok, EgressInfo.t()} | {:error, any()}

  @callback update_stream(
              egress_service :: Livekitex.EgressService.t(),
              request :: UpdateStreamRequest.t()
            ) :: {:ok, EgressInfo.t()} | {:error, any()}

  @callback list_egress(
              egress_service :: Livekitex.EgressService.t(),
              request :: ListEgressRequest.t()
            ) :: {:ok, ListEgressResponse.t()} | {:error, any()}

  @callback stop_egress(
              egress_service :: Livekitex.EgressService.t(),
              request :: StopEgressRequest.t()
            ) :: {:ok, EgressInfo.t()} | {:error, any()}
end

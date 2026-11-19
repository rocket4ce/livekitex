defmodule Livekitex.Proto.Livekit.SignalTarget do
  use Protobuf,
    enum: true,
    full_name: "livekit.SignalTarget",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :PUBLISHER, 0
  field :SUBSCRIBER, 1
end

defmodule Livekitex.Proto.Livekit.StreamState do
  use Protobuf,
    enum: true,
    full_name: "livekit.StreamState",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :ACTIVE, 0
  field :PAUSED, 1
end

defmodule Livekitex.Proto.Livekit.NegotiatedDataChannelID do
  use Protobuf,
    enum: true,
    full_name: "livekit.NegotiatedDataChannelID",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :NDCI_INVALID, 0
  field :NDCI_RELIABLE, 100
  field :NDCI_LOSSY, 101
  field :NDCI_DATA_TRACK, 102
end

defmodule Livekitex.Proto.Livekit.CandidateProtocol do
  use Protobuf,
    enum: true,
    full_name: "livekit.CandidateProtocol",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :UDP, 0
  field :TCP, 1
  field :TLS, 2
end

defmodule Livekitex.Proto.Livekit.LeaveRequest.Action do
  @moduledoc """
  indicates action clients should take on receiving this message
  """

  use Protobuf,
    enum: true,
    full_name: "livekit.LeaveRequest.Action",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :DISCONNECT, 0
  field :RESUME, 1
  field :RECONNECT, 2
end

defmodule Livekitex.Proto.Livekit.RequestResponse.Reason do
  use Protobuf,
    enum: true,
    full_name: "livekit.RequestResponse.Reason",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :OK, 0
  field :NOT_FOUND, 1
  field :NOT_ALLOWED, 2
  field :LIMIT_EXCEEDED, 3
  field :QUEUED, 4
  field :UNSUPPORTED_TYPE, 5
  field :UNCLASSIFIED_ERROR, 6
  field :INVALID_HANDLE, 7
  field :INVALID_NAME, 8
  field :DUPLICATE_HANDLE, 9
  field :DUPLICATE_NAME, 10
  field :INVALID_REQUEST, 11
end

defmodule Livekitex.Proto.Livekit.WrappedJoinRequest.Compression do
  use Protobuf,
    enum: true,
    full_name: "livekit.WrappedJoinRequest.Compression",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :NONE, 0
  field :GZIP, 1
end

defmodule Livekitex.Proto.Livekit.SignalRequest do
  use Protobuf,
    full_name: "livekit.SignalRequest",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  oneof :message, 0

  field :offer, 1, type: Livekitex.Proto.Livekit.SessionDescription, oneof: 0
  field :answer, 2, type: Livekitex.Proto.Livekit.SessionDescription, oneof: 0
  field :trickle, 3, type: Livekitex.Proto.Livekit.TrickleRequest, oneof: 0

  field :add_track, 4,
    type: Livekitex.Proto.Livekit.AddTrackRequest,
    json_name: "addTrack",
    oneof: 0

  field :mute, 5, type: Livekitex.Proto.Livekit.MuteTrackRequest, oneof: 0
  field :subscription, 6, type: Livekitex.Proto.Livekit.UpdateSubscription, oneof: 0

  field :track_setting, 7,
    type: Livekitex.Proto.Livekit.UpdateTrackSettings,
    json_name: "trackSetting",
    oneof: 0

  field :leave, 8, type: Livekitex.Proto.Livekit.LeaveRequest, oneof: 0

  field :update_layers, 10,
    type: Livekitex.Proto.Livekit.UpdateVideoLayers,
    json_name: "updateLayers",
    oneof: 0,
    deprecated: true

  field :subscription_permission, 11,
    type: Livekitex.Proto.Livekit.SubscriptionPermission,
    json_name: "subscriptionPermission",
    oneof: 0

  field :sync_state, 12, type: Livekitex.Proto.Livekit.SyncState, json_name: "syncState", oneof: 0
  field :simulate, 13, type: Livekitex.Proto.Livekit.SimulateScenario, oneof: 0
  field :ping, 14, type: :int64, oneof: 0

  field :update_metadata, 15,
    type: Livekitex.Proto.Livekit.UpdateParticipantMetadata,
    json_name: "updateMetadata",
    oneof: 0

  field :ping_req, 16, type: Livekitex.Proto.Livekit.Ping, json_name: "pingReq", oneof: 0

  field :update_audio_track, 17,
    type: Livekitex.Proto.Livekit.UpdateLocalAudioTrack,
    json_name: "updateAudioTrack",
    oneof: 0

  field :update_video_track, 18,
    type: Livekitex.Proto.Livekit.UpdateLocalVideoTrack,
    json_name: "updateVideoTrack",
    oneof: 0

  field :publish_data_track_request, 19,
    type: Livekitex.Proto.Livekit.PublishDataTrackRequest,
    json_name: "publishDataTrackRequest",
    oneof: 0

  field :unpublish_data_track_request, 20,
    type: Livekitex.Proto.Livekit.UnpublishDataTrackRequest,
    json_name: "unpublishDataTrackRequest",
    oneof: 0

  field :update_data_subscription, 21,
    type: Livekitex.Proto.Livekit.UpdateDataSubscription,
    json_name: "updateDataSubscription",
    oneof: 0

  field :store_data_blob_request, 22,
    type: Livekitex.Proto.Livekit.StoreDataBlobRequest,
    json_name: "storeDataBlobRequest",
    oneof: 0

  field :get_data_blob_request, 23,
    type: Livekitex.Proto.Livekit.GetDataBlobRequest,
    json_name: "getDataBlobRequest",
    oneof: 0
end

defmodule Livekitex.Proto.Livekit.SignalResponse do
  use Protobuf,
    full_name: "livekit.SignalResponse",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  oneof :message, 0

  field :join, 1, type: Livekitex.Proto.Livekit.JoinResponse, oneof: 0
  field :answer, 2, type: Livekitex.Proto.Livekit.SessionDescription, oneof: 0
  field :offer, 3, type: Livekitex.Proto.Livekit.SessionDescription, oneof: 0
  field :trickle, 4, type: Livekitex.Proto.Livekit.TrickleRequest, oneof: 0
  field :update, 5, type: Livekitex.Proto.Livekit.ParticipantUpdate, oneof: 0

  field :track_published, 6,
    type: Livekitex.Proto.Livekit.TrackPublishedResponse,
    json_name: "trackPublished",
    oneof: 0

  field :leave, 8, type: Livekitex.Proto.Livekit.LeaveRequest, oneof: 0
  field :mute, 9, type: Livekitex.Proto.Livekit.MuteTrackRequest, oneof: 0

  field :speakers_changed, 10,
    type: Livekitex.Proto.Livekit.SpeakersChanged,
    json_name: "speakersChanged",
    oneof: 0

  field :room_update, 11,
    type: Livekitex.Proto.Livekit.RoomUpdate,
    json_name: "roomUpdate",
    oneof: 0

  field :connection_quality, 12,
    type: Livekitex.Proto.Livekit.ConnectionQualityUpdate,
    json_name: "connectionQuality",
    oneof: 0

  field :stream_state_update, 13,
    type: Livekitex.Proto.Livekit.StreamStateUpdate,
    json_name: "streamStateUpdate",
    oneof: 0

  field :subscribed_quality_update, 14,
    type: Livekitex.Proto.Livekit.SubscribedQualityUpdate,
    json_name: "subscribedQualityUpdate",
    oneof: 0

  field :subscription_permission_update, 15,
    type: Livekitex.Proto.Livekit.SubscriptionPermissionUpdate,
    json_name: "subscriptionPermissionUpdate",
    oneof: 0

  field :refresh_token, 16, type: :string, json_name: "refreshToken", oneof: 0, deprecated: false

  field :track_unpublished, 17,
    type: Livekitex.Proto.Livekit.TrackUnpublishedResponse,
    json_name: "trackUnpublished",
    oneof: 0

  field :pong, 18, type: :int64, oneof: 0
  field :reconnect, 19, type: Livekitex.Proto.Livekit.ReconnectResponse, oneof: 0
  field :pong_resp, 20, type: Livekitex.Proto.Livekit.Pong, json_name: "pongResp", oneof: 0

  field :subscription_response, 21,
    type: Livekitex.Proto.Livekit.SubscriptionResponse,
    json_name: "subscriptionResponse",
    oneof: 0

  field :request_response, 22,
    type: Livekitex.Proto.Livekit.RequestResponse,
    json_name: "requestResponse",
    oneof: 0

  field :track_subscribed, 23,
    type: Livekitex.Proto.Livekit.TrackSubscribed,
    json_name: "trackSubscribed",
    oneof: 0

  field :room_moved, 24,
    type: Livekitex.Proto.Livekit.RoomMovedResponse,
    json_name: "roomMoved",
    oneof: 0

  field :media_sections_requirement, 25,
    type: Livekitex.Proto.Livekit.MediaSectionsRequirement,
    json_name: "mediaSectionsRequirement",
    oneof: 0

  field :subscribed_audio_codec_update, 26,
    type: Livekitex.Proto.Livekit.SubscribedAudioCodecUpdate,
    json_name: "subscribedAudioCodecUpdate",
    oneof: 0

  field :publish_data_track_response, 27,
    type: Livekitex.Proto.Livekit.PublishDataTrackResponse,
    json_name: "publishDataTrackResponse",
    oneof: 0

  field :unpublish_data_track_response, 28,
    type: Livekitex.Proto.Livekit.UnpublishDataTrackResponse,
    json_name: "unpublishDataTrackResponse",
    oneof: 0

  field :data_track_subscriber_handles, 29,
    type: Livekitex.Proto.Livekit.DataTrackSubscriberHandles,
    json_name: "dataTrackSubscriberHandles",
    oneof: 0

  field :store_data_blob_response, 30,
    type: Livekitex.Proto.Livekit.StoreDataBlobResponse,
    json_name: "storeDataBlobResponse",
    oneof: 0

  field :get_data_blob_response, 31,
    type: Livekitex.Proto.Livekit.GetDataBlobResponse,
    json_name: "getDataBlobResponse",
    oneof: 0
end

defmodule Livekitex.Proto.Livekit.SimulcastCodec do
  use Protobuf,
    full_name: "livekit.SimulcastCodec",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :codec, 1, type: :string
  field :cid, 2, type: :string
  field :layers, 4, repeated: true, type: Livekitex.Proto.Livekit.VideoLayer

  field :video_layer_mode, 5,
    type: Livekitex.Proto.Livekit.VideoLayer.Mode,
    json_name: "videoLayerMode",
    enum: true
end

defmodule Livekitex.Proto.Livekit.AddTrackRequest do
  use Protobuf,
    full_name: "livekit.AddTrackRequest",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :cid, 1, type: :string
  field :name, 2, type: :string
  field :type, 3, type: Livekitex.Proto.Livekit.TrackType, enum: true
  field :width, 4, type: :uint32
  field :height, 5, type: :uint32
  field :muted, 6, type: :bool
  field :disable_dtx, 7, type: :bool, json_name: "disableDtx", deprecated: true
  field :source, 8, type: Livekitex.Proto.Livekit.TrackSource, enum: true
  field :layers, 9, repeated: true, type: Livekitex.Proto.Livekit.VideoLayer

  field :simulcast_codecs, 10,
    repeated: true,
    type: Livekitex.Proto.Livekit.SimulcastCodec,
    json_name: "simulcastCodecs"

  field :sid, 11, type: :string
  field :stereo, 12, type: :bool, deprecated: true
  field :disable_red, 13, type: :bool, json_name: "disableRed"
  field :encryption, 14, type: Livekitex.Proto.Livekit.Encryption.Type, enum: true
  field :stream, 15, type: :string

  field :backup_codec_policy, 16,
    type: Livekitex.Proto.Livekit.BackupCodecPolicy,
    json_name: "backupCodecPolicy",
    enum: true

  field :audio_features, 17,
    repeated: true,
    type: Livekitex.Proto.Livekit.AudioTrackFeature,
    json_name: "audioFeatures",
    enum: true

  field :packet_trailer_features, 18,
    repeated: true,
    type: Livekitex.Proto.Livekit.PacketTrailerFeature,
    json_name: "packetTrailerFeatures",
    enum: true
end

defmodule Livekitex.Proto.Livekit.PublishDataTrackRequest do
  use Protobuf,
    full_name: "livekit.PublishDataTrackRequest",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :pub_handle, 1, type: :uint32, json_name: "pubHandle"
  field :name, 2, type: :string
  field :encryption, 3, type: Livekitex.Proto.Livekit.Encryption.Type, enum: true

  field :frame_encoding, 4,
    proto3_optional: true,
    type: Livekitex.Proto.Livekit.DataTrackFrameEncoding,
    json_name: "frameEncoding"

  field :schema, 5, proto3_optional: true, type: Livekitex.Proto.Livekit.DataTrackSchemaId
end

defmodule Livekitex.Proto.Livekit.PublishDataTrackResponse do
  use Protobuf,
    full_name: "livekit.PublishDataTrackResponse",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :info, 1, type: Livekitex.Proto.Livekit.DataTrackInfo
end

defmodule Livekitex.Proto.Livekit.UnpublishDataTrackRequest do
  use Protobuf,
    full_name: "livekit.UnpublishDataTrackRequest",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :pub_handle, 1, type: :uint32, json_name: "pubHandle"
end

defmodule Livekitex.Proto.Livekit.UnpublishDataTrackResponse do
  use Protobuf,
    full_name: "livekit.UnpublishDataTrackResponse",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :info, 1, type: Livekitex.Proto.Livekit.DataTrackInfo
end

defmodule Livekitex.Proto.Livekit.DataTrackSubscriberHandles.PublishedDataTrack do
  use Protobuf,
    full_name: "livekit.DataTrackSubscriberHandles.PublishedDataTrack",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :publisher_identity, 1, type: :string, json_name: "publisherIdentity"
  field :publisher_sid, 2, type: :string, json_name: "publisherSid"
  field :track_sid, 3, type: :string, json_name: "trackSid"
end

defmodule Livekitex.Proto.Livekit.DataTrackSubscriberHandles.SubHandlesEntry do
  use Protobuf,
    full_name: "livekit.DataTrackSubscriberHandles.SubHandlesEntry",
    map: true,
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :key, 1, type: :uint32
  field :value, 2, type: Livekitex.Proto.Livekit.DataTrackSubscriberHandles.PublishedDataTrack
end

defmodule Livekitex.Proto.Livekit.DataTrackSubscriberHandles do
  use Protobuf,
    full_name: "livekit.DataTrackSubscriberHandles",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :sub_handles, 1,
    repeated: true,
    type: Livekitex.Proto.Livekit.DataTrackSubscriberHandles.SubHandlesEntry,
    json_name: "subHandles",
    map: true
end

defmodule Livekitex.Proto.Livekit.TrickleRequest do
  use Protobuf,
    full_name: "livekit.TrickleRequest",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :candidateInit, 1, type: :string
  field :target, 2, type: Livekitex.Proto.Livekit.SignalTarget, enum: true
  field :final, 3, type: :bool
end

defmodule Livekitex.Proto.Livekit.MuteTrackRequest do
  use Protobuf,
    full_name: "livekit.MuteTrackRequest",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :sid, 1, type: :string
  field :muted, 2, type: :bool
end

defmodule Livekitex.Proto.Livekit.JoinResponse do
  use Protobuf,
    full_name: "livekit.JoinResponse",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :room, 1, type: Livekitex.Proto.Livekit.Room
  field :participant, 2, type: Livekitex.Proto.Livekit.ParticipantInfo

  field :other_participants, 3,
    repeated: true,
    type: Livekitex.Proto.Livekit.ParticipantInfo,
    json_name: "otherParticipants"

  field :server_version, 4, type: :string, json_name: "serverVersion"

  field :ice_servers, 5,
    repeated: true,
    type: Livekitex.Proto.Livekit.ICEServer,
    json_name: "iceServers"

  field :subscriber_primary, 6, type: :bool, json_name: "subscriberPrimary"
  field :alternative_url, 7, type: :string, json_name: "alternativeUrl"

  field :client_configuration, 8,
    type: Livekitex.Proto.Livekit.ClientConfiguration,
    json_name: "clientConfiguration"

  field :server_region, 9, type: :string, json_name: "serverRegion"
  field :ping_timeout, 10, type: :int32, json_name: "pingTimeout"
  field :ping_interval, 11, type: :int32, json_name: "pingInterval"
  field :server_info, 12, type: Livekitex.Proto.Livekit.ServerInfo, json_name: "serverInfo"
  field :sif_trailer, 13, type: :bytes, json_name: "sifTrailer"

  field :enabled_publish_codecs, 14,
    repeated: true,
    type: Livekitex.Proto.Livekit.Codec,
    json_name: "enabledPublishCodecs"

  field :fast_publish, 15, type: :bool, json_name: "fastPublish"
end

defmodule Livekitex.Proto.Livekit.ReconnectResponse do
  use Protobuf,
    full_name: "livekit.ReconnectResponse",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :ice_servers, 1,
    repeated: true,
    type: Livekitex.Proto.Livekit.ICEServer,
    json_name: "iceServers"

  field :client_configuration, 2,
    type: Livekitex.Proto.Livekit.ClientConfiguration,
    json_name: "clientConfiguration"

  field :server_info, 3, type: Livekitex.Proto.Livekit.ServerInfo, json_name: "serverInfo"
  field :last_message_seq, 4, type: :uint32, json_name: "lastMessageSeq"
end

defmodule Livekitex.Proto.Livekit.TrackPublishedResponse do
  use Protobuf,
    full_name: "livekit.TrackPublishedResponse",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :cid, 1, type: :string
  field :track, 2, type: Livekitex.Proto.Livekit.TrackInfo
end

defmodule Livekitex.Proto.Livekit.TrackUnpublishedResponse do
  use Protobuf,
    full_name: "livekit.TrackUnpublishedResponse",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :track_sid, 1, type: :string, json_name: "trackSid"
end

defmodule Livekitex.Proto.Livekit.SessionDescription.MidToTrackIdEntry do
  use Protobuf,
    full_name: "livekit.SessionDescription.MidToTrackIdEntry",
    map: true,
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :key, 1, type: :string
  field :value, 2, type: :string
end

defmodule Livekitex.Proto.Livekit.SessionDescription do
  use Protobuf,
    full_name: "livekit.SessionDescription",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :type, 1, type: :string
  field :sdp, 2, type: :string
  field :id, 3, type: :uint32

  field :mid_to_track_id, 4,
    repeated: true,
    type: Livekitex.Proto.Livekit.SessionDescription.MidToTrackIdEntry,
    json_name: "midToTrackId",
    map: true,
    deprecated: false
end

defmodule Livekitex.Proto.Livekit.ParticipantUpdate do
  use Protobuf,
    full_name: "livekit.ParticipantUpdate",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :participants, 1, repeated: true, type: Livekitex.Proto.Livekit.ParticipantInfo
end

defmodule Livekitex.Proto.Livekit.UpdateSubscription do
  use Protobuf,
    full_name: "livekit.UpdateSubscription",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :track_sids, 1, repeated: true, type: :string, json_name: "trackSids"
  field :subscribe, 2, type: :bool

  field :participant_tracks, 3,
    repeated: true,
    type: Livekitex.Proto.Livekit.ParticipantTracks,
    json_name: "participantTracks"
end

defmodule Livekitex.Proto.Livekit.UpdateDataSubscription.Update do
  use Protobuf,
    full_name: "livekit.UpdateDataSubscription.Update",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :track_sid, 1, type: :string, json_name: "trackSid"
  field :subscribe, 2, type: :bool
  field :options, 3, type: Livekitex.Proto.Livekit.DataTrackSubscriptionOptions
end

defmodule Livekitex.Proto.Livekit.UpdateDataSubscription do
  use Protobuf,
    full_name: "livekit.UpdateDataSubscription",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :updates, 1, repeated: true, type: Livekitex.Proto.Livekit.UpdateDataSubscription.Update
end

defmodule Livekitex.Proto.Livekit.StoreDataBlobRequest do
  use Protobuf,
    full_name: "livekit.StoreDataBlobRequest",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :request_id, 1, type: :uint32, json_name: "requestId", deprecated: false
  field :blob, 2, type: Livekitex.Proto.Livekit.DataBlob
end

defmodule Livekitex.Proto.Livekit.StoreDataBlobResponse do
  use Protobuf,
    full_name: "livekit.StoreDataBlobResponse",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :request_id, 1, type: :uint32, json_name: "requestId", deprecated: false
  field :key, 2, type: Livekitex.Proto.Livekit.DataBlobKey
end

defmodule Livekitex.Proto.Livekit.GetDataBlobRequest do
  use Protobuf,
    full_name: "livekit.GetDataBlobRequest",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :request_id, 1, type: :uint32, json_name: "requestId", deprecated: false
  field :participant_identity, 2, type: :string, json_name: "participantIdentity"
  field :key, 3, type: Livekitex.Proto.Livekit.DataBlobKey
end

defmodule Livekitex.Proto.Livekit.GetDataBlobResponse do
  use Protobuf,
    full_name: "livekit.GetDataBlobResponse",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :request_id, 1, type: :uint32, json_name: "requestId", deprecated: false
  field :blob, 2, type: Livekitex.Proto.Livekit.DataBlob
end

defmodule Livekitex.Proto.Livekit.UpdateTrackSettings do
  use Protobuf,
    full_name: "livekit.UpdateTrackSettings",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :track_sids, 1, repeated: true, type: :string, json_name: "trackSids"
  field :disabled, 3, type: :bool
  field :quality, 4, type: Livekitex.Proto.Livekit.VideoQuality, enum: true
  field :width, 5, type: :uint32
  field :height, 6, type: :uint32
  field :fps, 7, type: :uint32
  field :priority, 8, type: :uint32
end

defmodule Livekitex.Proto.Livekit.UpdateLocalAudioTrack do
  use Protobuf,
    full_name: "livekit.UpdateLocalAudioTrack",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :track_sid, 1, type: :string, json_name: "trackSid"
  field :features, 2, repeated: true, type: Livekitex.Proto.Livekit.AudioTrackFeature, enum: true
end

defmodule Livekitex.Proto.Livekit.UpdateLocalVideoTrack do
  use Protobuf,
    full_name: "livekit.UpdateLocalVideoTrack",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :track_sid, 1, type: :string, json_name: "trackSid"
  field :width, 2, type: :uint32
  field :height, 3, type: :uint32
end

defmodule Livekitex.Proto.Livekit.LeaveRequest do
  use Protobuf,
    full_name: "livekit.LeaveRequest",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :can_reconnect, 1, type: :bool, json_name: "canReconnect"
  field :reason, 2, type: Livekitex.Proto.Livekit.DisconnectReason, enum: true
  field :action, 3, type: Livekitex.Proto.Livekit.LeaveRequest.Action, enum: true
  field :regions, 4, type: Livekitex.Proto.Livekit.RegionSettings
end

defmodule Livekitex.Proto.Livekit.UpdateVideoLayers do
  @moduledoc """
  message to indicate published video track dimensions are changing
  """

  use Protobuf,
    deprecated: true,
    full_name: "livekit.UpdateVideoLayers",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :track_sid, 1, type: :string, json_name: "trackSid"
  field :layers, 2, repeated: true, type: Livekitex.Proto.Livekit.VideoLayer
end

defmodule Livekitex.Proto.Livekit.UpdateParticipantMetadata.AttributesEntry do
  use Protobuf,
    full_name: "livekit.UpdateParticipantMetadata.AttributesEntry",
    map: true,
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :key, 1, type: :string
  field :value, 2, type: :string
end

defmodule Livekitex.Proto.Livekit.UpdateParticipantMetadata do
  use Protobuf,
    full_name: "livekit.UpdateParticipantMetadata",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :metadata, 1, type: :string, deprecated: false
  field :name, 2, type: :string, deprecated: false

  field :attributes, 3,
    repeated: true,
    type: Livekitex.Proto.Livekit.UpdateParticipantMetadata.AttributesEntry,
    map: true,
    deprecated: false

  field :request_id, 4, type: :uint32, json_name: "requestId", deprecated: false
end

defmodule Livekitex.Proto.Livekit.ICEServer do
  use Protobuf,
    full_name: "livekit.ICEServer",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :urls, 1, repeated: true, type: :string
  field :username, 2, type: :string, deprecated: false
  field :credential, 3, type: :string, deprecated: false
end

defmodule Livekitex.Proto.Livekit.SpeakersChanged do
  use Protobuf,
    full_name: "livekit.SpeakersChanged",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :speakers, 1, repeated: true, type: Livekitex.Proto.Livekit.SpeakerInfo
end

defmodule Livekitex.Proto.Livekit.RoomUpdate do
  use Protobuf,
    full_name: "livekit.RoomUpdate",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :room, 1, type: Livekitex.Proto.Livekit.Room
end

defmodule Livekitex.Proto.Livekit.ConnectionQualityInfo do
  use Protobuf,
    full_name: "livekit.ConnectionQualityInfo",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :participant_sid, 1, type: :string, json_name: "participantSid"
  field :quality, 2, type: Livekitex.Proto.Livekit.ConnectionQuality, enum: true
  field :score, 3, type: :float
end

defmodule Livekitex.Proto.Livekit.ConnectionQualityUpdate do
  use Protobuf,
    full_name: "livekit.ConnectionQualityUpdate",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :updates, 1, repeated: true, type: Livekitex.Proto.Livekit.ConnectionQualityInfo
end

defmodule Livekitex.Proto.Livekit.StreamStateInfo do
  use Protobuf,
    full_name: "livekit.StreamStateInfo",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :participant_sid, 1, type: :string, json_name: "participantSid"
  field :track_sid, 2, type: :string, json_name: "trackSid"
  field :state, 3, type: Livekitex.Proto.Livekit.StreamState, enum: true
end

defmodule Livekitex.Proto.Livekit.StreamStateUpdate do
  use Protobuf,
    full_name: "livekit.StreamStateUpdate",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :stream_states, 1,
    repeated: true,
    type: Livekitex.Proto.Livekit.StreamStateInfo,
    json_name: "streamStates"
end

defmodule Livekitex.Proto.Livekit.SubscribedQuality do
  use Protobuf,
    full_name: "livekit.SubscribedQuality",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :quality, 1, type: Livekitex.Proto.Livekit.VideoQuality, enum: true
  field :enabled, 2, type: :bool
end

defmodule Livekitex.Proto.Livekit.SubscribedCodec do
  use Protobuf,
    full_name: "livekit.SubscribedCodec",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :codec, 1, type: :string
  field :qualities, 2, repeated: true, type: Livekitex.Proto.Livekit.SubscribedQuality
end

defmodule Livekitex.Proto.Livekit.SubscribedQualityUpdate do
  use Protobuf,
    full_name: "livekit.SubscribedQualityUpdate",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :track_sid, 1, type: :string, json_name: "trackSid"

  field :subscribed_qualities, 2,
    repeated: true,
    type: Livekitex.Proto.Livekit.SubscribedQuality,
    json_name: "subscribedQualities",
    deprecated: true

  field :subscribed_codecs, 3,
    repeated: true,
    type: Livekitex.Proto.Livekit.SubscribedCodec,
    json_name: "subscribedCodecs"
end

defmodule Livekitex.Proto.Livekit.SubscribedAudioCodecUpdate do
  use Protobuf,
    full_name: "livekit.SubscribedAudioCodecUpdate",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :track_sid, 1, type: :string, json_name: "trackSid"

  field :subscribed_audio_codecs, 2,
    repeated: true,
    type: Livekitex.Proto.Livekit.SubscribedAudioCodec,
    json_name: "subscribedAudioCodecs"
end

defmodule Livekitex.Proto.Livekit.TrackPermission do
  use Protobuf,
    full_name: "livekit.TrackPermission",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :participant_sid, 1, type: :string, json_name: "participantSid"
  field :all_tracks, 2, type: :bool, json_name: "allTracks"
  field :track_sids, 3, repeated: true, type: :string, json_name: "trackSids"
  field :participant_identity, 4, type: :string, json_name: "participantIdentity"
end

defmodule Livekitex.Proto.Livekit.SubscriptionPermission do
  use Protobuf,
    full_name: "livekit.SubscriptionPermission",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :all_participants, 1, type: :bool, json_name: "allParticipants"

  field :track_permissions, 2,
    repeated: true,
    type: Livekitex.Proto.Livekit.TrackPermission,
    json_name: "trackPermissions"
end

defmodule Livekitex.Proto.Livekit.SubscriptionPermissionUpdate do
  use Protobuf,
    full_name: "livekit.SubscriptionPermissionUpdate",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :participant_sid, 1, type: :string, json_name: "participantSid"
  field :track_sid, 2, type: :string, json_name: "trackSid"
  field :allowed, 3, type: :bool
end

defmodule Livekitex.Proto.Livekit.RoomMovedResponse do
  use Protobuf,
    full_name: "livekit.RoomMovedResponse",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :room, 1, type: Livekitex.Proto.Livekit.Room
  field :token, 2, type: :string, deprecated: false
  field :participant, 3, type: Livekitex.Proto.Livekit.ParticipantInfo

  field :other_participants, 4,
    repeated: true,
    type: Livekitex.Proto.Livekit.ParticipantInfo,
    json_name: "otherParticipants"
end

defmodule Livekitex.Proto.Livekit.SyncState do
  use Protobuf,
    full_name: "livekit.SyncState",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :answer, 1, type: Livekitex.Proto.Livekit.SessionDescription
  field :subscription, 2, type: Livekitex.Proto.Livekit.UpdateSubscription

  field :publish_tracks, 3,
    repeated: true,
    type: Livekitex.Proto.Livekit.TrackPublishedResponse,
    json_name: "publishTracks"

  field :data_channels, 4,
    repeated: true,
    type: Livekitex.Proto.Livekit.DataChannelInfo,
    json_name: "dataChannels"

  field :offer, 5, type: Livekitex.Proto.Livekit.SessionDescription
  field :track_sids_disabled, 6, repeated: true, type: :string, json_name: "trackSidsDisabled"

  field :datachannel_receive_states, 7,
    repeated: true,
    type: Livekitex.Proto.Livekit.DataChannelReceiveState,
    json_name: "datachannelReceiveStates"

  field :publish_data_tracks, 8,
    repeated: true,
    type: Livekitex.Proto.Livekit.PublishDataTrackResponse,
    json_name: "publishDataTracks"

  field :data_subscription, 9,
    type: Livekitex.Proto.Livekit.UpdateDataSubscription,
    json_name: "dataSubscription"
end

defmodule Livekitex.Proto.Livekit.DataChannelReceiveState do
  use Protobuf,
    full_name: "livekit.DataChannelReceiveState",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :publisher_sid, 1, type: :string, json_name: "publisherSid"
  field :last_seq, 2, type: :uint32, json_name: "lastSeq"
end

defmodule Livekitex.Proto.Livekit.DataChannelInfo do
  use Protobuf,
    full_name: "livekit.DataChannelInfo",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :label, 1, type: :string
  field :id, 2, type: :uint32
  field :target, 3, type: Livekitex.Proto.Livekit.SignalTarget, enum: true
end

defmodule Livekitex.Proto.Livekit.SimulateScenario do
  use Protobuf,
    full_name: "livekit.SimulateScenario",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  oneof :scenario, 0

  field :speaker_update, 1, type: :int32, json_name: "speakerUpdate", oneof: 0
  field :node_failure, 2, type: :bool, json_name: "nodeFailure", oneof: 0
  field :migration, 3, type: :bool, oneof: 0
  field :server_leave, 4, type: :bool, json_name: "serverLeave", oneof: 0

  field :switch_candidate_protocol, 5,
    type: Livekitex.Proto.Livekit.CandidateProtocol,
    json_name: "switchCandidateProtocol",
    enum: true,
    oneof: 0

  field :subscriber_bandwidth, 6, type: :int64, json_name: "subscriberBandwidth", oneof: 0

  field :disconnect_signal_on_resume, 7,
    type: :bool,
    json_name: "disconnectSignalOnResume",
    oneof: 0

  field :disconnect_signal_on_resume_no_messages, 8,
    type: :bool,
    json_name: "disconnectSignalOnResumeNoMessages",
    oneof: 0

  field :leave_request_full_reconnect, 9,
    type: :bool,
    json_name: "leaveRequestFullReconnect",
    oneof: 0
end

defmodule Livekitex.Proto.Livekit.Ping do
  use Protobuf, full_name: "livekit.Ping", protoc_gen_elixir_version: "0.17.1", syntax: :proto3

  field :timestamp, 1, type: :int64
  field :rtt, 2, type: :int64
end

defmodule Livekitex.Proto.Livekit.Pong do
  use Protobuf, full_name: "livekit.Pong", protoc_gen_elixir_version: "0.17.1", syntax: :proto3

  field :last_ping_timestamp, 1, type: :int64, json_name: "lastPingTimestamp"
  field :timestamp, 2, type: :int64
end

defmodule Livekitex.Proto.Livekit.RegionSettings do
  use Protobuf,
    full_name: "livekit.RegionSettings",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :regions, 1, repeated: true, type: Livekitex.Proto.Livekit.RegionInfo
end

defmodule Livekitex.Proto.Livekit.RegionInfo do
  use Protobuf,
    full_name: "livekit.RegionInfo",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :region, 1, type: :string
  field :url, 2, type: :string
  field :distance, 3, type: :int64
end

defmodule Livekitex.Proto.Livekit.SubscriptionResponse do
  use Protobuf,
    full_name: "livekit.SubscriptionResponse",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :track_sid, 1, type: :string, json_name: "trackSid"
  field :err, 2, type: Livekitex.Proto.Livekit.SubscriptionError, enum: true
end

defmodule Livekitex.Proto.Livekit.RequestResponse do
  use Protobuf,
    full_name: "livekit.RequestResponse",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  oneof :request, 0

  field :request_id, 1, type: :uint32, json_name: "requestId", deprecated: false
  field :reason, 2, type: Livekitex.Proto.Livekit.RequestResponse.Reason, enum: true
  field :message, 3, type: :string
  field :trickle, 4, type: Livekitex.Proto.Livekit.TrickleRequest, oneof: 0

  field :add_track, 5,
    type: Livekitex.Proto.Livekit.AddTrackRequest,
    json_name: "addTrack",
    oneof: 0

  field :mute, 6, type: Livekitex.Proto.Livekit.MuteTrackRequest, oneof: 0

  field :update_metadata, 7,
    type: Livekitex.Proto.Livekit.UpdateParticipantMetadata,
    json_name: "updateMetadata",
    oneof: 0

  field :update_audio_track, 8,
    type: Livekitex.Proto.Livekit.UpdateLocalAudioTrack,
    json_name: "updateAudioTrack",
    oneof: 0

  field :update_video_track, 9,
    type: Livekitex.Proto.Livekit.UpdateLocalVideoTrack,
    json_name: "updateVideoTrack",
    oneof: 0

  field :publish_data_track, 10,
    type: Livekitex.Proto.Livekit.PublishDataTrackRequest,
    json_name: "publishDataTrack",
    oneof: 0

  field :unpublish_data_track, 11,
    type: Livekitex.Proto.Livekit.UnpublishDataTrackRequest,
    json_name: "unpublishDataTrack",
    oneof: 0
end

defmodule Livekitex.Proto.Livekit.TrackSubscribed do
  use Protobuf,
    full_name: "livekit.TrackSubscribed",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :track_sid, 1, type: :string, json_name: "trackSid"
end

defmodule Livekitex.Proto.Livekit.ConnectionSettings do
  use Protobuf,
    full_name: "livekit.ConnectionSettings",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :auto_subscribe, 1, type: :bool, json_name: "autoSubscribe"
  field :adaptive_stream, 2, type: :bool, json_name: "adaptiveStream"

  field :subscriber_allow_pause, 3,
    proto3_optional: true,
    type: :bool,
    json_name: "subscriberAllowPause"

  field :disable_ice_lite, 4, type: :bool, json_name: "disableIceLite"

  field :auto_subscribe_data_track, 5,
    proto3_optional: true,
    type: :bool,
    json_name: "autoSubscribeDataTrack"
end

defmodule Livekitex.Proto.Livekit.JoinRequest.ParticipantAttributesEntry do
  use Protobuf,
    full_name: "livekit.JoinRequest.ParticipantAttributesEntry",
    map: true,
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :key, 1, type: :string
  field :value, 2, type: :string
end

defmodule Livekitex.Proto.Livekit.JoinRequest do
  use Protobuf,
    full_name: "livekit.JoinRequest",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :client_info, 1, type: Livekitex.Proto.Livekit.ClientInfo, json_name: "clientInfo"

  field :connection_settings, 2,
    type: Livekitex.Proto.Livekit.ConnectionSettings,
    json_name: "connectionSettings"

  field :metadata, 3, type: :string, deprecated: false

  field :participant_attributes, 4,
    repeated: true,
    type: Livekitex.Proto.Livekit.JoinRequest.ParticipantAttributesEntry,
    json_name: "participantAttributes",
    map: true,
    deprecated: false

  field :add_track_requests, 5,
    repeated: true,
    type: Livekitex.Proto.Livekit.AddTrackRequest,
    json_name: "addTrackRequests"

  field :publisher_offer, 6,
    type: Livekitex.Proto.Livekit.SessionDescription,
    json_name: "publisherOffer"

  field :reconnect, 7, type: :bool

  field :reconnect_reason, 8,
    type: Livekitex.Proto.Livekit.ReconnectReason,
    json_name: "reconnectReason",
    enum: true

  field :participant_sid, 9, type: :string, json_name: "participantSid"
  field :sync_state, 10, type: Livekitex.Proto.Livekit.SyncState, json_name: "syncState"
end

defmodule Livekitex.Proto.Livekit.WrappedJoinRequest do
  use Protobuf,
    full_name: "livekit.WrappedJoinRequest",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :compression, 1, type: Livekitex.Proto.Livekit.WrappedJoinRequest.Compression, enum: true
  field :join_request, 2, type: :bytes, json_name: "joinRequest"
end

defmodule Livekitex.Proto.Livekit.MediaSectionsRequirement do
  use Protobuf,
    full_name: "livekit.MediaSectionsRequirement",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  field :num_audios, 1, type: :uint32, json_name: "numAudios"
  field :num_videos, 2, type: :uint32, json_name: "numVideos"
end

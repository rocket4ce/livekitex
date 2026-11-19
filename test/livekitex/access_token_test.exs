defmodule Livekitex.AccessTokenTest do
  use ExUnit.Case, async: true

  alias Livekitex.{AccessToken, TokenVerifier}
  alias Livekitex.Grants.{ClaimGrant, VideoGrant}
  alias Livekitex.Proto.Livekit.{RoomAgentDispatch, RoomConfiguration}

  doctest Livekitex.Grants.VideoGrant

  defp claims(token) do
    {:ok, jwt, _} = AccessToken.to_jwt(token)
    {:ok, claims} = Joken.peek_claims(jwt)
    claims
  end

  defp new(opts \\ []), do: AccessToken.create("devkey", "secret", opts)

  test "registered claims and 6h default ttl" do
    claims =
      new(identity: "alice")
      |> AccessToken.set_video_grant(room_join: true, room: "r")
      |> claims()

    assert claims["iss"] == "devkey"
    assert claims["sub"] == "alice"
    assert claims["exp"] - claims["nbf"] == 6 * 3600
    assert claims["iat"] == claims["nbf"]
    assert claims["video"] == %{"roomJoin" => true, "room" => "r"}
  end

  test "serializes every video grant field in camelCase" do
    grant =
      VideoGrant.new(
        room_create: true,
        room_list: true,
        room_record: true,
        room_admin: true,
        room_join: true,
        room: "r",
        destination_room: "r2",
        can_publish: false,
        can_subscribe: true,
        can_publish_data: false,
        can_publish_sources: [:camera, "MICROPHONE"],
        can_update_own_metadata: true,
        can_subscribe_metrics: true,
        can_manage_agent_session: true,
        ingress_admin: true,
        hidden: true,
        recorder: true,
        agent: true
      )

    assert VideoGrant.to_map(grant) == %{
             "roomCreate" => true,
             "roomList" => true,
             "roomRecord" => true,
             "roomAdmin" => true,
             "roomJoin" => true,
             "room" => "r",
             "destinationRoom" => "r2",
             "canPublish" => false,
             "canSubscribe" => true,
             "canPublishData" => false,
             "canPublishSources" => ["camera", "microphone"],
             "canUpdateOwnMetadata" => true,
             "canSubscribeMetrics" => true,
             "canManageAgentSession" => true,
             "ingressAdmin" => true,
             "hidden" => true,
             "recorder" => true,
             "agent" => true
           }
  end

  test "new grant groups, kind and extra claims" do
    claims =
      new(identity: "worker", kind: :agent)
      |> AccessToken.set_agent_grant(admin: true, dispatch_admin: true, simulation_admin: false)
      |> AccessToken.set_inference_grant(perform: true)
      |> AccessToken.set_observability_grant(write: true)
      |> AccessToken.set_sip_grant(call: true)
      |> AccessToken.set_kind_details([:cloud_agent])
      |> AccessToken.put_claim("agentEndpoint", %{"call" => true, "agentName" => "a"})
      |> claims()

    assert claims["kind"] == "agent"
    assert claims["kindDetails"] == ["cloud_agent"]

    assert claims["agent"] == %{
             "admin" => true,
             "dispatchAdmin" => true,
             "simulationAdmin" => false
           }

    assert claims["inference"] == %{"perform" => true}
    assert claims["observability"] == %{"write" => true}
    assert claims["sip"] == %{"call" => true}
    assert claims["agentEndpoint"] == %{"call" => true, "agentName" => "a"}
    refute Map.has_key?(claims, "video")
  end

  test "room config with agent dispatch round-trips" do
    token =
      new(identity: "alice")
      |> AccessToken.set_video_grant(room_join: true, room: "r")
      |> AccessToken.set_room_config(
        empty_timeout: 120,
        tags: %{team: "a"},
        agents: [[agent_name: "support", metadata: "{}"]]
      )

    assert claims(token)["roomConfig"] == %{
             "emptyTimeout" => 120,
             "tags" => %{"team" => "a"},
             "agents" => [%{"agentName" => "support", "metadata" => "{}"}]
           }

    {:ok, jwt, _} = AccessToken.to_jwt(token)
    {:ok, grant} = TokenVerifier.verify(TokenVerifier.new("devkey", "secret"), jwt)

    assert %ClaimGrant{
             identity: "alice",
             room_config: %RoomConfiguration{
               empty_timeout: 120,
               agents: [%RoomAgentDispatch{agent_name: "support"}]
             }
           } = grant
  end

  test "joining a room requires an identity" do
    assert {:error, :identity_required} =
             new() |> AccessToken.set_video_grant(room_join: true) |> AccessToken.to_jwt()

    assert_raise ArgumentError, fn ->
      new() |> AccessToken.set_video_grant(room_join: true) |> AccessToken.to_jwt!()
    end
  end

  test "service tokens without identity are allowed" do
    assert {:ok, _jwt, claims} =
             new() |> AccessToken.set_video_grant(room_list: true) |> AccessToken.to_jwt()

    refute Map.has_key?(claims, "sub")
  end

  test "rejects unknown grant fields and kinds" do
    assert_raise KeyError, fn -> AccessToken.set_video_grant(new(), room_jion: true) end
    assert_raise ArgumentError, fn -> AccessToken.set_kind(new(), :robot) end
  end

  test "custom ttl, metadata, attributes and name" do
    claims =
      new(identity: "a", ttl: 60, name: "A", metadata: "m", attributes: %{"k" => "v"})
      |> AccessToken.set_video_grant(room_join: true, room: "r")
      |> AccessToken.set_room_preset("preset")
      |> claims()

    assert claims["exp"] - claims["nbf"] == 60

    assert %{
             "name" => "A",
             "metadata" => "m",
             "attributes" => %{"k" => "v"},
             "roomPreset" => "preset"
           } = claims
  end
end

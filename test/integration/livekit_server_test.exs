defmodule Livekitex.Integration.LiveKitServerTest do
  @moduledoc """
  Runs against a local `livekit-server --dev` (devkey/secret on 127.0.0.1:7880):

      livekit-server --dev
      mix test --only integration

  Egress, Ingress and SIP need extra services, so without them the server answers with
  an error; these tests only check that the request is authorized and routed.
  """
  use ExUnit.Case, async: false

  @moduletag :integration

  alias Livekitex.{
    AgentDispatchService,
    EgressService,
    Error,
    IngressService,
    RoomService,
    SIPService
  }

  setup_all do
    url = System.get_env("LIVEKIT_TEST_URL", "http://127.0.0.1:7880")
    client = Livekitex.Client.new(url: url, api_key: "devkey", api_secret: "secret", retry: false)

    case RoomService.list_rooms(client) do
      {:ok, _} ->
        {:ok, client: client}

      {:error, error} ->
        raise "LiveKit dev server not reachable at #{url}: #{Exception.message(error)}"
    end
  end

  setup %{client: client} do
    room = "it-#{System.unique_integer([:positive])}"
    on_exit(fn -> RoomService.delete_room(client, room) end)
    {:ok, room: room}
  end

  test "room lifecycle", %{client: client, room: room} do
    assert {:ok, %{name: ^room, metadata: "m1"}} =
             RoomService.create_room(client, room, empty_timeout: 60, metadata: "m1")

    assert {:ok, rooms} = RoomService.list_rooms(client, names: [room])
    assert Enum.map(rooms, & &1.name) == [room]

    assert {:ok, %{metadata: "m2"}} = RoomService.update_room_metadata(client, room, "m2")
    assert {:ok, []} = RoomService.list_participants(client, room)
    assert {:error, %Error{code: :not_found}} = RoomService.get_participant(client, room, "ghost")
    assert :ok = RoomService.send_data(client, room, "hello", topic: "it")
    assert :ok = RoomService.delete_room(client, room)
  end

  test "agent dispatch lifecycle", %{client: client, room: room} do
    {:ok, _} = RoomService.create_room(client, room)

    assert {:ok, %{id: id, agent_name: "it-agent", metadata: "x"}} =
             AgentDispatchService.create_dispatch(client, room, "it-agent", metadata: "x")

    # The server also adds an automatic dispatch (empty agent_name) for unnamed agents.
    named = fn ->
      client
      |> AgentDispatchService.list_dispatch(room)
      |> elem(1)
      |> Enum.filter(&(&1.agent_name == "it-agent"))
    end

    assert [%{id: ^id}] = named.()
    assert {:ok, %{id: ^id}} = AgentDispatchService.get_dispatch(client, room, id)
    assert {:ok, %{id: ^id}} = AgentDispatchService.delete_dispatch(client, room, id)
    assert [] = named.()
  end

  test "room config agents create a dispatch with the room", %{client: client, room: room} do
    {:ok, _} = RoomService.create_room(client, room, agents: [[agent_name: "auto-agent"]])
    assert {:ok, [%{agent_name: "auto-agent"}]} = AgentDispatchService.list_dispatch(client, room)
  end

  test "egress, ingress and SIP calls are authorized", %{client: client} do
    for result <- [
          EgressService.list_egress(client),
          IngressService.list_ingress(client),
          SIPService.list_inbound_trunks(client)
        ] do
      case result do
        {:ok, _} ->
          :ok

        {:error, %Error{code: code}} ->
          refute code in [:unauthenticated, :permission_denied, :bad_route]
      end
    end
  end

  test "wrong credentials are rejected", %{client: client} do
    bad = %{client | api_secret: "wrong"}
    assert {:error, %Error{code: :unauthenticated, msg: msg}} = RoomService.list_rooms(bad)
    refute msg =~ "eyJ"
  end
end

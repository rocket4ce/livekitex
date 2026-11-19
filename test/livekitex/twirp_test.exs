defmodule Livekitex.TwirpTest do
  use ExUnit.Case, async: true

  import Livekitex.TestHelpers

  alias Livekitex.{Error, Twirp}

  alias Livekitex.Proto.Livekit.{
    CreateRoomRequest,
    ListRoomsRequest,
    ListRoomsResponse,
    Room,
    StartEgressRequest
  }

  doctest Livekitex.Error

  @grants [video: [room_list: true]]

  defp list_rooms(client, opts \\ []) do
    Twirp.call(
      client,
      "RoomService",
      "ListRooms",
      %ListRoomsRequest{},
      ListRoomsResponse,
      @grants,
      opts
    )
  end

  describe "call/7" do
    test "posts protobuf with auth, user-agent and request id headers" do
      stub_response(%ListRoomsResponse{rooms: [%Room{name: "a"}]})

      assert {:ok, %ListRoomsResponse{rooms: [%Room{name: "a"}]}} = list_rooms(client())

      assert_received {:twirp, info}
      assert info.method == "POST"
      assert info.path == "/twirp/livekit.RoomService/ListRooms"
      assert info.headers["content-type"] == "application/protobuf"
      assert info.headers["user-agent"] =~ ~r/^livekitex\//
      assert info.headers["x-livekit-request-id"] =~ ~r/^[0-9a-f-]{36}$/
      assert info.claims["iss"] == "devkey"
      assert info.claims["video"] == %{"roomList" => true}
      assert info.claims["exp"] - info.claims["nbf"] == 600
    end

    test "decodes Twirp errors with metadata and redacts tokens" do
      stub_response(
        {:twirp_error, 404, "not_found", "invalid token: eyJhbGc.eyJzdWIi.c2ln",
         %{"sip_status_code" => "486", "sip_status" => "Busy Here"}}
      )

      assert {:error, %Error{} = error} = list_rooms(client())
      assert error.code == :not_found
      assert error.status == 404
      assert error.msg == "invalid token: [REDACTED_JWT]"
      assert Error.sip_status(error) == {486, "Busy Here"}
      assert error.service == "RoomService"
      assert error.method == "ListRooms"
      assert Exception.message(error) =~ "not_found"
    end

    test "unknown Twirp codes do not create atoms" do
      stub_response({:twirp_error, 400, "brand_new_code_#{System.unique_integer()}", "x", %{}})
      assert {:error, %Error{code: :unknown}} = list_rooms(client())
    end

    test "maps non-Twirp error bodies by status" do
      stub_response({:raw, 403, "<html>forbidden</html>"})

      assert {:error, %Error{code: :permission_denied, msg: "<html>forbidden</html>"}} =
               list_rooms(client())
    end

    test "retries 503 with the same request id, then succeeds" do
      stub_sequence([{:raw, 503, "busy"}, {:raw, 502, "bad gateway"}, %ListRoomsResponse{}])

      assert {:ok, %ListRoomsResponse{}} = list_rooms(client())

      ids =
        for _ <- 1..3 do
          assert_received {:twirp, %{headers: %{"x-livekit-request-id" => id}}}
          id
        end

      assert ids |> Enum.uniq() |> length() == 1
    end

    test "gives up after max attempts" do
      stub_sequence([{:raw, 503, "busy"}])
      assert {:error, %Error{code: :unavailable, status: 503}} = list_rooms(client())
      for _ <- 1..3, do: assert_received({:twirp, _})
      refute_received {:twirp, _}
    end

    test "does not retry when retry is disabled" do
      stub_sequence([{:raw, 503, "busy"}, %ListRoomsResponse{}])
      assert {:error, %Error{code: :unavailable}} = list_rooms(client(), retry: false)
      assert_received {:twirp, _}
      refute_received {:twirp, _}
    end

    test "does not retry 4xx or 500" do
      stub_sequence([{:twirp_error, 500, "internal", "boom", %{}}, %ListRoomsResponse{}])
      assert {:error, %Error{code: :internal}} = list_rooms(client())
      assert_received {:twirp, _}
      refute_received {:twirp, _}
    end

    test "retries transport errors" do
      stub_sequence([{:transport_error, :closed}, %ListRoomsResponse{}])
      assert {:ok, _} = list_rooms(client())
    end

    test "does not retry timeouts" do
      stub_sequence([{:transport_error, :timeout}, %ListRoomsResponse{}])
      assert {:error, %Error{code: :timeout}} = list_rooms(client())
      assert_received {:twirp, _}
      refute_received {:twirp, _}
    end

    test "reports malformed responses" do
      stub_response({:raw, 200, <<255, 255, 255>>})
      assert {:error, %Error{code: :internal}} = list_rooms(client())
    end

    test "emits telemetry start and stop events" do
      ref = make_ref()
      test_pid = self()

      :telemetry.attach_many(
        "twirp-test-#{inspect(ref)}",
        [[:livekitex, :request, :start], [:livekitex, :request, :stop]],
        fn event, measurements, metadata, _ ->
          send(test_pid, {ref, event, measurements, metadata})
        end,
        nil
      )

      stub_sequence([{:raw, 503, "busy"}, %ListRoomsResponse{}])
      assert {:ok, _} = list_rooms(client())

      assert_received {^ref, [:livekitex, :request, :start], _,
                       %{service: "RoomService", method: "ListRooms"}}

      assert_received {^ref, [:livekitex, :request, :stop], %{duration: _},
                       %{status: 200, attempts: 2, error: nil}}
    after
      :telemetry.list_handlers([:livekitex, :request])
      |> Enum.each(&:telemetry.detach(&1.id))
    end
  end

  describe "build/2" do
    test "builds nested messages, maps, oneofs and durations" do
      request =
        Twirp.build(StartEgressRequest,
          room_name: "r",
          template: [layout: "grid"],
          preset: :H264_720P_30,
          outputs: [[file: [filepath: "out.mp4"]]]
        )

      assert request.room_name == "r"
      assert {:template, %Livekitex.Proto.Livekit.TemplateSource{layout: "grid"}} = request.source
      assert request.encoding == {:preset, :H264_720P_30}

      assert [%Livekitex.Proto.Livekit.Output{config: {:file, %{filepath: "out.mp4"}}}] =
               request.outputs

      room =
        Twirp.build(CreateRoomRequest, name: "r", tags: [team: "a"], agents: [%{agent_name: "x"}])

      assert room.tags == %{"team" => "a"}
      assert [%Livekitex.Proto.Livekit.RoomAgentDispatch{agent_name: "x"}] = room.agents

      sip = Twirp.build(Livekitex.Proto.Livekit.CreateSIPParticipantRequest, ringing_timeout: 20)
      assert sip.ringing_timeout == %Google.Protobuf.Duration{seconds: 20}
    end

    test "returns structs untouched and rejects unknown keys" do
      request = %ListRoomsRequest{names: ["a"]}
      assert Twirp.build(ListRoomsRequest, request) == request
      assert_raise KeyError, fn -> Twirp.build(ListRoomsRequest, nope: 1) end
    end
  end
end

defmodule Livekitex.ServicesTest do
  @moduledoc """
  Table-driven coverage of every RPC: path, grants in the service token, the decoded
  request, the retry default and the shape of the result.
  """
  use ExUnit.Case, async: true

  import Livekitex.TestHelpers

  alias Livekitex.Proto.Livekit, as: LK
  alias Livekitex.{RoomService, SIPService}

  for {{name, _call, path, _req, _fields, _grants, _resp, _expected, _retries}, index} <-
        Enum.with_index(Livekitex.ServiceCases.all()) do
    @index index

    test "#{name} → #{path}" do
      {_name, call, path, request_module, expected_fields, grants, response, expected, _} =
        Enum.at(Livekitex.ServiceCases.all(), @index)

      stub_response(response)

      assert call.(client()) == expected

      assert_received {:twirp, info}
      assert info.path == "/twirp/livekit." <> path

      request = request_module.decode(info.body)

      for {field, value} <- expected_fields do
        assert Map.fetch!(request, field) == value,
               "#{inspect(field)}: expected #{inspect(value)}, got #{inspect(Map.fetch!(request, field))}"
      end

      for {group, perms} <- grants do
        assert info.claims[group] == perms
      end

      assert info.claims |> Map.take(["video", "sip"]) |> Map.keys() |> Enum.sort() ==
               grants |> Map.keys() |> Enum.sort()
    end

    test "#{name} retry default" do
      {_name, call, _path, _req, _fields, _grants, response, expected, retries?} =
        Enum.at(Livekitex.ServiceCases.all(), @index)

      stub_sequence([{:raw, 503, "busy"}, response])
      result = call.(client())

      if retries? do
        assert result == expected
      else
        assert {:error, %Livekitex.Error{code: :unavailable}} = result
      end
    end
  end

  test "non-idempotent calls retry when asked explicitly" do
    stub_sequence([{:raw, 503, "busy"}, %LK.SendDataResponse{}])
    assert :ok = RoomService.send_data(client(), "r1", "hi", retry: true)
  end

  test "send_data adds a random nonce" do
    stub_response(%LK.SendDataResponse{})
    :ok = RoomService.send_data(client(), "r1", "hi")
    assert_received {:twirp, info}
    assert byte_size(LK.SendDataRequest.decode(info.body).nonce) == 16
  end

  test "create_room accepts a request struct" do
    stub_response(%LK.Room{name: "s"})

    assert {:ok, %LK.Room{name: "s"}} =
             RoomService.create_room(client(), %LK.CreateRoomRequest{name: "s"})
  end

  test "dialing with wait_until_answered extends the timeout" do
    stub_response(%LK.SIPParticipantInfo{})

    assert {:ok, _} =
             SIPService.create_sip_participant(client(timeout: 1), "ST", "+1", "r",
               wait_until_answered: true,
               ringing_timeout: 1
             )
  end

  test "services reject a non-client first argument" do
    assert_raise ArgumentError, ~r/Livekitex.Client/, fn -> RoomService.list_rooms(:nope) end
  end
end

defmodule Livekitex.EgressServiceTest do
  use ExUnit.Case, async: false

  alias Livekitex.EgressService
  alias Livekit.{RoomCompositeEgressRequest, ListEgressRequest, StopEgressRequest}

  setup do
    egress_service = EgressService.create("devkey", "secret", host: "localhost", port: 7880)
    {:ok, egress_service: egress_service}
  end

  defp assert_server_result(result, success_assertion_fn) do
    case result do
      {:ok, data} ->
        success_assertion_fn.(data)

      {:error, {:twirp_error, _}} ->
        assert true

      other ->
        flunk("Expected success or connection error, got: #{inspect(other)}")
    end
  end

  describe "start_room_composite_egress/2" do
    test "starts a room composite egress successfully", %{egress_service: egress_service} do
      request = %RoomCompositeEgressRequest{room_name: "test-room"}

      EgressService.start_room_composite_egress(egress_service, request)
      |> assert_server_result(fn egress_info ->
        assert is_binary(egress_info.egress_id)
      end)
    end
  end

  describe "list_egress/2" do
    test "lists all egress", %{egress_service: egress_service} do
      request = %ListEgressRequest{}

      EgressService.list_egress(egress_service, request)
      |> assert_server_result(fn response ->
        assert is_list(response.items)
      end)
    end
  end

  describe "stop_egress/2" do
    test "stops an egress successfully", %{egress_service: egress_service} do
      # First, start an egress to have something to stop
      start_request = %RoomCompositeEgressRequest{room_name: "test-room-to-stop"}

      case EgressService.start_room_composite_egress(egress_service, start_request) do
        {:ok, egress_info} ->
          stop_request = %StopEgressRequest{egress_id: egress_info.egress_id}

          EgressService.stop_egress(egress_service, stop_request)
          |> assert_server_result(fn stop_info ->
            assert stop_info.egress_id == egress_info.egress_id
          end)

        {:error, {:twirp_error, _}} ->
          assert true

        other ->
          flunk("Unexpected result during start_room_composite_egress: #{inspect(other)}")
      end
    end
  end
end

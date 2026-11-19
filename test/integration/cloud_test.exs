defmodule Livekitex.Integration.CloudTest do
  @moduledoc """
  Read-only checks against a LiveKit Cloud project:

      LIVEKIT_CLOUD_URL=wss://<project>.livekit.cloud \\
      LIVEKIT_CLOUD_API_KEY=... LIVEKIT_CLOUD_API_SECRET=... \\
      mix test --only cloud

  Nothing here purchases numbers, places calls or creates billable resources.
  """
  use ExUnit.Case, async: false

  @moduletag :cloud

  alias Livekitex.{PhoneNumberService, RoomService, SIPService}

  setup_all do
    vars = ~w(LIVEKIT_CLOUD_URL LIVEKIT_CLOUD_API_KEY LIVEKIT_CLOUD_API_SECRET)

    case Enum.map(vars, &System.get_env/1) do
      [url, key, secret] when is_binary(url) and is_binary(key) and is_binary(secret) ->
        {:ok, client: Livekitex.Client.new(url: url, api_key: key, api_secret: secret)}

      _ ->
        raise "set #{Enum.join(vars, ", ")} to run cloud tests"
    end
  end

  test "lists rooms over TLS", %{client: client} do
    assert String.starts_with?(client.base_url, "https://")
    assert {:ok, rooms} = RoomService.list_rooms(client)
    assert is_list(rooms)
  end

  test "lists SIP trunks and dispatch rules", %{client: client} do
    assert {:ok, _} = SIPService.list_inbound_trunks(client)
    assert {:ok, _} = SIPService.list_outbound_trunks(client)
    assert {:ok, _} = SIPService.list_dispatch_rules(client)
  end

  test "lists egress and ingress (roomRecord / ingressAdmin grants)", %{client: client} do
    assert {:ok, %{items: _}} = Livekitex.EgressService.list_egress(client)
    assert {:ok, %{items: _}} = Livekitex.IngressService.list_ingress(client)
  end

  test "searches and lists phone numbers", %{client: client} do
    assert {:ok, %{items: _}} = PhoneNumberService.search_phone_numbers(client, "US", limit: 1)
    assert {:ok, %{items: _}} = PhoneNumberService.list_phone_numbers(client, limit: 5)
  end
end

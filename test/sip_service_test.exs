defmodule Livekitex.SIPServiceTest do
  use ExUnit.Case, async: true

  alias Livekitex.SIPService

  setup do
    # Use Tesla.Mock for all HTTP calls in this test module
    Application.put_env(:livekitex, :tesla_adapter, Tesla.Mock)
    # Example credentials and host; replace with real ones in your env when needed
    Application.put_env(
      :livekitex,
      :api_key,
      System.get_env("LIVEKIT_API_KEY") || "APIasdasdasd"
    )

    Application.put_env(
      :livekitex,
      :api_secret,
      System.get_env("LIVEKIT_API_SECRET") || "asdasdasdasdasd"
    )

    Application.put_env(
      :livekitex,
      :host,
      System.get_env("LIVEKIT_HOST") || "test-asdasdasdasd.livekit.cloud"
    )

    Tesla.Mock.mock(fn env ->
      cond do
        String.ends_with?(env.url, "/twirp/livekit.SIP/CreateSIPParticipant") ->
          # Validate token header exists
          assert Enum.any?(env.headers, fn {k, v} ->
                   k == "authorization" and String.starts_with?(v, "Bearer ")
                 end)

          {:ok,
           %Tesla.Env{
             status: 200,
             body:
               ~s({"participant_id":"p1","participant_identity":"id","room_name":"room","sip_call_id":"call"})
           }}

        String.ends_with?(env.url, "/twirp/livekit.SIP/TransferSIPParticipant") ->
          {:ok, %Tesla.Env{status: 200, body: ~s({})}}

        true ->
          flunk("Unexpected request: #{inspect(env)}")
      end
    end)

    :ok
  end

  defp svc() do
    SIPService.create("asdasdasd", "asdasdasd", host: "test-asdasdasd.livekit.cloud")
  end

  test "create participant happy path" do
    {:ok, info} =
      SIPService.create_participant(svc(), %{
        "sip_trunk_id" => "t1",
        "sip_call_to" => "+15550199",
        "room_name" => "room"
      })

    assert info["participant_id"] == "p1"
  end

  test "transfer participant ok" do
    assert :ok =
             SIPService.transfer_participant(svc(), %{
               "participant_identity" => "id",
               "room_name" => "room",
               "transfer_to" => "+15550000"
             })
  end
end

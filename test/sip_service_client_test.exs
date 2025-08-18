defmodule Livekitex.SIPServiceClientTest do
  use ExUnit.Case, async: true

  alias Livekitex.TwirpUtils
  alias Livekitex.SIPServiceClient

  setup do
    Tesla.Mock.mock(fn env ->
      cond do
        String.ends_with?(env.url, "/twirp/livekit.SIP/CreateSIPInboundTrunk") ->
          assert env.method == :post
          assert {"content-type", "application/json"} in env.headers

          assert Enum.any?(env.headers, fn {k, v} ->
                   k == "authorization" and String.starts_with?(v, "Bearer ")
                 end)

          {:ok,
           %Tesla.Env{status: 200, body: ~s({"trunk":{"sip_trunk_id":"in-1","name":"Inbound"}})}}

        String.ends_with?(env.url, "/twirp/livekit.SIP/ListSIPOutboundTrunk") ->
          assert env.method == :post
          {:ok, %Tesla.Env{status: 200, body: ~s({"items":[]})}}

        String.ends_with?(env.url, "/twirp/livekit.SIP/CreateSIPOutboundTrunk") ->
          {:ok, %Tesla.Env{status: 400, body: ~s({"code":"permission_denied","msg":"nope"})}}

        true ->
          flunk("Unexpected request: #{inspect(env)}")
      end
    end)

    :ok
  end

  defp client() do
    # Base URL doesn't matter under Tesla.Mock
    middleware = [
      {Tesla.Middleware.BaseUrl, "https://example.com"},
      {Tesla.Middleware.Headers, [{"content-type", "application/json"}]}
    ]

    adapter = {Tesla.Adapter.Finch, name: Livekitex.Finch}
    Tesla.client(middleware, adapter)
  end

  test "create inbound trunk returns trunk info" do
    {:ok, resp} = SIPServiceClient.create_inbound_trunk(client(), "token", %{"name" => "Inbound"})
    assert %{"trunk" => %{"sip_trunk_id" => "in-1"}} = resp
  end

  test "list outbound trunks returns items" do
    {:ok, resp} = SIPServiceClient.list_outbound_trunks(client(), "token", %{})
    assert %{"items" => []} = resp
  end

  test "twirp error is mapped" do
    assert {:error, %{code: :permission_denied, msg: "nope"}} =
             SIPServiceClient.create_outbound_trunk(client(), "token", %{"name" => "x"})
  end
end

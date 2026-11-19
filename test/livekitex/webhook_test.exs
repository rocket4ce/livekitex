defmodule Livekitex.WebhookTest do
  use ExUnit.Case, async: true

  import Livekitex.TestHelpers
  import Plug.Test
  import Plug.Conn

  alias Livekitex.Proto.Livekit.WebhookEvent
  alias Livekitex.Webhook
  alias Livekitex.Webhook.Plug, as: WebhookPlug

  @opts [api_key: "devkey", api_secret: "secret"]

  @body ~s({"event":"participant_joined","id":"EV_1","createdAt":"1795053868",) <>
          ~s("room":{"sid":"RM_1","name":"r1"},"participant":{"sid":"PA_1","identity":"alice","kind":"AGENT",) <>
          ~s("kindDetails":["CLOUD_AGENT"],"someNewField":true},"roomEndReason":"ROOM_END_API_DELETE"})

  describe "receive_event/3" do
    test "verifies and decodes a signed event" do
      auth = sign_webhook(@body)

      assert {:ok, %WebhookEvent{} = event} = Webhook.receive_event(@body, auth, @opts)
      assert event.event == "participant_joined"
      assert event.created_at == 1_795_053_868
      assert event.room.name == "r1"
      assert event.participant.kind == :AGENT
      assert event.participant.kind_details == [:CLOUD_AGENT]
      assert event.room_end_reason == :ROOM_END_API_DELETE
    end

    test "accepts an optional Bearer prefix" do
      assert {:ok, _} = Webhook.receive_event(@body, "Bearer " <> sign_webhook(@body), @opts)
      assert {:ok, _} = Webhook.receive_event(@body, "bearer " <> sign_webhook(@body), @opts)
    end

    test "rejects a tampered body" do
      auth = sign_webhook(@body)
      assert {:error, :hash_mismatch} = Webhook.receive_event(@body <> " ", auth, @opts)
    end

    test "rejects wrong secret, wrong issuer, missing hash and missing header" do
      assert {:error, :invalid_signature} =
               Webhook.receive_event(@body, sign_webhook(@body, api_secret: "other"), @opts)

      assert {:error, :invalid_issuer} =
               Webhook.receive_event(@body, sign_webhook(@body, api_key: "otherkey"), @opts)

      assert {:error, :missing_sha256} =
               Webhook.receive_event(@body, sign_webhook(@body, sha256: ""), @opts)

      assert {:error, :missing_auth_header} = Webhook.receive_event(@body, nil, @opts)
    end

    test "supports several keys" do
      auth = sign_webhook(@body, api_key: "key2", api_secret: "s2")
      keys = %{"devkey" => "secret", "key2" => "s2"}
      assert {:ok, _} = Webhook.receive_event(@body, auth, keys: keys)

      assert {:error, :invalid_issuer} =
               Webhook.receive_event(@body, auth, keys: %{"devkey" => "secret"})
    end

    test "rejects invalid JSON after verification" do
      body = "not json"
      assert {:error, {:invalid_body, _}} = Webhook.receive_event(body, sign_webhook(body), @opts)
    end

    test "verifies a real webhook captured from livekit-server" do
      %{"authorization" => auth, "body" => body} =
        "test/fixtures/webhook_room_started.json" |> File.read!() |> Jason.decode!()

      # The captured token expired long ago; only the signature and hash are under test.
      opts = Keyword.put(@opts, :leeway, 100 * 365 * 24 * 3600)

      assert {:ok, %WebhookEvent{event: "room_started", room: %{name: "smoke-room"}}} =
               Webhook.receive_event(body, auth, opts)

      assert {:error, :hash_mismatch} = Webhook.receive_event(body <> "\n", auth, opts)
    end
  end

  describe "Webhook.Plug" do
    defmodule Handler do
      @behaviour Livekitex.Webhook.Handler
      def handle_event(event, conn), do: send(conn.private[:test_pid], {:webhook, event})
    end

    defp call_plug(conn, opts \\ []) do
      conn = put_private(conn, :test_pid, self())
      opts = WebhookPlug.init(Keyword.merge([handler: Handler] ++ @opts, opts))
      WebhookPlug.call(conn, opts)
    end

    defp webhook_conn(body, auth) do
      conn(:post, "/webhook", body)
      |> put_req_header("content-type", "application/webhook+json")
      |> put_req_header("authorization", auth)
    end

    test "handles a valid webhook" do
      conn = @body |> webhook_conn(sign_webhook(@body)) |> call_plug()
      assert conn.status == 200
      assert conn.halted
      assert_received {:webhook, %WebhookEvent{event: "participant_joined"}}
    end

    test "uses the raw body kept by BodyReader" do
      conn =
        @body
        |> webhook_conn(sign_webhook(@body))
        |> Plug.Parsers.call(
          Plug.Parsers.init(
            parsers: [:json],
            json_decoder: Jason,
            body_reader: {Livekitex.Webhook.BodyReader, :read_body, []}
          )
        )

      assert conn.body_params["event"] == "participant_joined"
      assert call_plug(conn).status == 200
      assert_received {:webhook, _}
    end

    test "rejects bad signatures with 401" do
      conn = @body |> webhook_conn(sign_webhook(@body, api_secret: "nope")) |> call_plug()
      assert conn.status == 401
      refute_received {:webhook, _}
    end

    test "rejects oversized bodies with 413" do
      conn = @body |> webhook_conn(sign_webhook(@body)) |> call_plug(max_body_length: 10)
      assert conn.status == 413
    end

    test "rejects non-POST with 405" do
      conn = conn(:get, "/webhook") |> call_plug()
      assert conn.status == 405
    end

    test "answers 500 when the handler fails" do
      conn =
        @body
        |> webhook_conn(sign_webhook(@body))
        |> call_plug(handler: fn _event, _conn -> {:error, :boom} end)

      assert conn.status == 500
    end
  end
end

# Livekitex

Elixir server SDK for [LiveKit](https://livekit.io). It covers access tokens, webhooks, and the
complete server API (rooms, egress, ingress, SIP, agent dispatch, connectors and phone numbers),
generated from [livekit/protocol](https://github.com/livekit/protocol) **v1.54.1**.

[![Hex Version](https://img.shields.io/hexpm/v/livekitex.svg)](https://hex.pm/packages/livekitex)
[![Documentation](https://img.shields.io/badge/docs-hexpm-blue.svg)](https://hexdocs.pm/livekitex)

| Area | Module | Twirp service |
|---|---|---|
| Rooms, participants, data, RPC | `Livekitex.RoomService` | `livekit.RoomService` (14 RPCs) |
| Recording and streaming | `Livekitex.EgressService` | `livekit.Egress` (10 RPCs, incl. `StartEgress`) |
| RTMP / WHIP / URL ingestion | `Livekitex.IngressService` | `livekit.Ingress` |
| SIP trunks, dispatch rules, calls | `Livekitex.SIPService` | `livekit.SIP` |
| LiveKit Agents dispatch | `Livekitex.AgentDispatchService` | `livekit.AgentDispatchService` |
| WhatsApp / Twilio *(experimental, Cloud)* | `Livekitex.ConnectorService` | `livekit.Connector` |
| Phone numbers *(experimental, Cloud)* | `Livekitex.PhoneNumberService` | `livekit.PhoneNumberService` |
| Access tokens | `Livekitex.AccessToken`, `Livekitex.TokenVerifier` | |
| Webhooks | `Livekitex.Webhook`, `Livekitex.Webhook.Plug` | |
| Token endpoint for client SDKs | `Livekitex.TokenSource.Plug` | |

> Upgrading from 0.1.x? See [Migrating from 0.1](#migrating-from-01).

## Installation

```elixir
def deps do
  [
    {:livekitex, "~> 0.2.0"}
  ]
end
```

Requires Elixir 1.16+.

## Configuration

```elixir
# config/runtime.exs
config :livekitex,
  url: System.fetch_env!("LIVEKIT_URL"),            # "wss://my-project.livekit.cloud" or "http://localhost:7880"
  api_key: System.fetch_env!("LIVEKIT_API_KEY"),
  api_secret: System.fetch_env!("LIVEKIT_API_SECRET")
```

Without application config, `LIVEKIT_URL`, `LIVEKIT_API_KEY` and `LIVEKIT_API_SECRET` are read from
the environment. `ws://` and `wss://` URLs are rewritten to `http://` and `https://`.

## The client

Every service function takes a `Livekitex.Client` and returns `{:ok, result}` / `:ok` or
`{:error, %Livekitex.Error{}}`. Results are the generated protobuf structs in
`Livekitex.Proto.Livekit`.

```elixir
client = Livekitex.client()                       # from config
client = Livekitex.Client.new(url: "wss://...", api_key: "...", api_secret: "...", timeout: 5_000)
```

Requests can be given as keyword lists. Nested messages are keyword lists too, and a `oneof`
member is set by its field name:

```elixir
alias Livekitex.EgressService

EgressService.start_egress(client, "standup",
  template: [layout: "grid"],
  outputs: [[file: [filepath: "recordings/{room_name}-{time}.mp4"]]]
)
```

You can also pass the generated struct, e.g. `%Livekitex.Proto.Livekit.CreateRoomRequest{}`.

## Access tokens

```elixir
alias Livekitex.AccessToken

{:ok, jwt, _claims} =
  AccessToken.create(api_key, api_secret, identity: "alice", name: "Alice")
  |> AccessToken.set_video_grant(room_join: true, room: "standup", can_publish_sources: [:camera, :microphone])
  |> AccessToken.to_jwt()

# Or, with configured credentials:
{:ok, jwt} = Livekitex.room_join_token("alice", "standup", can_publish: false)
```

The default TTL is 6 hours (as in the official SDKs). Supported grants:

* `set_video_grant/2`: `room_join`, `room`, `room_create`, `room_list`, `room_record`, `room_admin`,
  `can_publish`, `can_subscribe`, `can_publish_data`, `can_publish_sources`,
  `can_update_own_metadata`, `can_subscribe_metrics`, `can_manage_agent_session`,
  `destination_room`, `ingress_admin`, `hidden`, `recorder`, `agent`
* `set_sip_grant/2` (`admin`, `call`), `set_agent_grant/2` (`admin`, `dispatch_admin`,
  `simulation_admin`), `set_inference_grant/2`, `set_observability_grant/2`
* `set_kind/2` (`:agent`, `:sip`, ...), `set_kind_details/2`, `set_attributes/2`,
  `set_metadata/2`, `set_room_preset/2`, `set_room_config/2`
* `put_claim/3` for any other top-level claim

Verify tokens with `Livekitex.TokenVerifier`, which checks signature, issuer and expiry.

## Rooms and participants

```elixir
alias Livekitex.RoomService

{:ok, room} = RoomService.create_room(client, "standup", empty_timeout: 300, max_participants: 10)
{:ok, rooms} = RoomService.list_rooms(client)
{:ok, participants} = RoomService.list_participants(client, "standup")
{:ok, participant} = RoomService.get_participant(client, "standup", "alice")

RoomService.update_participant(client, "standup", "alice",
  attributes: %{"role" => "host"},
  permission: [can_publish: true, can_subscribe: true, can_publish_data: true]
)

RoomService.mute_published_track(client, "standup", "alice", "TR_xxx", true)
RoomService.send_data(client, "standup", "hello", topic: "chat", destination_identities: ["bob"])
RoomService.forward_participant(client, "standup", "alice", "overflow-room")
RoomService.move_participant(client, "standup", "alice", "breakout-1")
{:ok, response} = RoomService.perform_rpc(client, "standup", "agent", "get_summary", "{}", response_timeout_ms: 5_000)
RoomService.remove_participant(client, "standup", "alice")
RoomService.delete_room(client, "standup")
```

## Egress

```elixir
# Unified API
{:ok, info} =
  EgressService.start_egress(client, "standup",
    template: [layout: "speaker"],
    outputs: [[file: [filepath: "standup.mp4"]], [stream: [urls: ["rtmp://live.example.com/key"]]]]
  )

# Classic APIs
EgressService.start_room_composite_egress(client, "standup", layout: "grid", file_outputs: [[filepath: "a.mp4"]])
EgressService.start_track_egress(client, "standup", track_id: "TR_xxx", websocket_url: "wss://sink")
EgressService.update_layout(client, info.egress_id, "grid")
{:ok, %{items: active, next_page_token: _}} = EgressService.list_egress(client, room_name: "standup", active: true)
EgressService.stop_egress(client, info.egress_id)
```

## Ingress

```elixir
{:ok, ingress} =
  Livekitex.IngressService.create_ingress(client, :RTMP_INPUT,
    name: "obs", room_name: "live", participant_identity: "streamer")

ingress.url        # stream here
ingress.stream_key
```

## SIP

```elixir
alias Livekitex.SIPService

{:ok, trunk} =
  SIPService.create_outbound_trunk(client,
    name: "Carrier", address: "sip.carrier.com", numbers: ["+15105550100"],
    auth_username: "user", auth_password: "pass")

case SIPService.create_sip_participant(client, trunk.sip_trunk_id, "+15105550123", "call-123",
       participant_identity: "callee", wait_until_answered: true, ringing_timeout: 30) do
  {:ok, participant} -> participant
  {:error, error} -> Livekitex.Error.sip_status(error)   # e.g. {486, "Busy Here"}
end

{:ok, _rule} =
  SIPService.create_dispatch_rule(client, [dispatch_rule_individual: [room_prefix: "call-"]],
    trunk_ids: ["ST_xxx"],
    room_config: [agents: [[agent_name: "phone-agent"]]])

SIPService.transfer_sip_participant(client, "call-123", "callee", "tel:+15105550199")
```

Trunks also support `update_*_trunk/3` (partial updates with `ListUpdate`), `replace_*_trunk/3`,
`get_*_trunk/2`, `list_*_trunks/2` and `delete_trunk/2`; dispatch rules have the same set.

## LiveKit Agents from Elixir

Agents themselves run on the official [LiveKit Agents](https://docs.livekit.io/agents/) frameworks
(Python or Node.js). Elixir controls *when and where* they run:

```elixir
# 1. Dispatch an agent to an existing room
{:ok, dispatch} =
  Livekitex.AgentDispatchService.create_dispatch(client, "support-42", "support-agent",
    metadata: Jason.encode!(%{customer_id: 42}))

{:ok, dispatches} = Livekitex.AgentDispatchService.list_dispatch(client, "support-42")

# 2. Or dispatch it when the room is created by a participant token
{:ok, jwt} =
  Livekitex.room_join_token("customer-42", "support-42",
    room_config: [agents: [[agent_name: "support-agent"]]])

# 3. Or when your server creates the room
Livekitex.RoomService.create_room(client, "support-42", agents: [[agent_name: "support-agent"]])
```

Then follow the job lifecycle with the `agent_job_pending`, `agent_job_started` and
`agent_job_ended` webhooks, and talk to the agent with `RoomService.perform_rpc/6` or
`RoomService.send_data/4`.

A native Elixir agent worker is not part of this library: it would require a WebRTC media
stack. See [docs/agents_roadmap.md](https://github.com/rocket4ce/livekitex/blob/main/docs/agents_roadmap.md).

## Webhooks

`Livekitex.Webhook.Plug` verifies the signature, the issuer, the expiry and the SHA-256 of the
raw body, then calls your handler with a `Livekitex.Proto.Livekit.WebhookEvent`:

```elixir
# router.ex
forward "/livekit/webhook", Livekitex.Webhook.Plug, handler: MyApp.LiveKitWebhooks

defmodule MyApp.LiveKitWebhooks do
  @behaviour Livekitex.Webhook.Handler
  require Logger

  @impl true
  def handle_event(%{event: "participant_joined", room: room, participant: p}, _conn) do
    Logger.info("#{p.identity} joined #{room.name}")
  end

  def handle_event(%{event: "agent_job_ended", job: job}, _conn), do: MyApp.Jobs.finished(job)
  def handle_event(_event, _conn), do: :ok
end
```

Phoenix parses `application/webhook+json` bodies in the endpoint, so keep a copy of the raw body:

```elixir
# endpoint.ex
plug Plug.Parsers,
  parsers: [:urlencoded, :multipart, :json],
  pass: ["*/*"],
  json_decoder: Phoenix.json_library(),
  body_reader: {Livekitex.Webhook.BodyReader, :read_body, []}
```

Without the plug: `Livekitex.Webhook.receive_event(raw_body, authorization_header)`.

## Token endpoint for client SDKs

`Livekitex.TokenSource.Plug` implements LiveKit's standard token endpoint, used by
`TokenSource.endpoint(...)` in the JavaScript, Swift, Kotlin, Flutter and Unity SDKs:

```elixir
# inside an authenticated pipeline
forward "/api/livekit/token", Livekitex.TokenSource.Plug,
  authorize: &MyApp.LiveKitAuth.authorize/2,
  server_url: "wss://my-project.livekit.cloud"

defmodule MyApp.LiveKitAuth do
  # `request` comes from the client: decide what this user may do.
  def authorize(conn, request) do
    user = conn.assigns.current_user
    {:ok, identity: "user-#{user.id}", name: user.name, room: request.room_name || "lobby"}
  end
end
```

The client's `room_config` (for example, which agents to dispatch) is ignored unless you pass
`allow_room_config: true`, and requests that resolve to no room are rejected with `400`, since a
join token without a room would be valid for every room.

## Errors, retries and timeouts

`%Livekitex.Error{}` carries the Twirp `code` (`:not_found`, `:permission_denied`, ...), `msg`,
`meta`, HTTP `status` and the `request_id` sent as `x-livekit-request-id`. Transport failures use
`:transport_error` or `:timeout`.

Requests time out after 10 s by default (connect and receive; `timeout:` per client or per
call). Connection errors and HTTP 502/503/504 are retried up to 3 times with exponential backoff,
using the same request id. Calls whose repetition has side effects (dialing, starting egress,
sending data, creating ingresses/trunks/rules/dispatches, moving participants, purchasing
numbers, ...) are never retried unless you pass `retry: true`.
Configure with `retry: false` or `retry: [max_attempts: 5, base_delay: 100]`.

## Telemetry

Every request emits `[:livekitex, :request, :start | :stop | :exception]` with `service`,
`method`, `request_id`, `status`, `attempts` and `error` metadata.

## Testing your application

Route requests to a [`Req.Test`](https://hexdocs.pm/req/Req.Test.html) stub:

```elixir
client = Livekitex.Client.new(req_options: [plug: {Req.Test, MyApp.LiveKitStub}])

Req.Test.stub(MyApp.LiveKitStub, fn conn ->
  conn
  |> Plug.Conn.put_resp_content_type("application/protobuf")
  |> Plug.Conn.send_resp(200, Protobuf.encode(%Livekitex.Proto.Livekit.Room{name: "test"}))
end)
```

## Migrating from 0.1

0.2.0 is a breaking release.

* **Client**: service functions take a `%Livekitex.Client{}` (`Livekitex.client/1`) instead of
  per-service structs. `RoomService.create(url, key, secret)`, `EgressService.create(...)`,
  `Livekitex.room_service()` and friends still build a client but are deprecated.
* **Protobuf modules** moved from `Livekit.*` to `Livekitex.Proto.Livekit.*` (this also avoids
  clashing with the `livekit` Hex package). `%Livekit.RoomCompositeEgressRequest{}` becomes
  `%Livekitex.Proto.Livekit.RoomCompositeEgressRequest{}`, or just a keyword list.
* **Results** are protobuf structs everywhere (`%Livekitex.Proto.Livekit.Room{}` instead of
  `%Livekitex.Room{}`; SIP no longer returns string-keyed maps). List calls return lists,
  except paginated ones (`list_egress`, `list_ingress`, phone numbers), which return the
  response struct with `items` and `next_page_token`.
* `RoomService.list_rooms(client, names: [...])` takes the filter as an option.
* **Errors** are `%Livekitex.Error{}` instead of `{:twirp_error, ...}` tuples.
* **SIP**: functions are typed and renamed where needed (`create_participant` →
  `create_sip_participant/5`, `transfer_participant` → `transfer_sip_participant/5`,
  `list_inbound_trunks/2`, `list_dispatch_rules/2`).
* **Webhooks**: the old `validate_webhook` function is now `Livekitex.Webhook.receive_event/3`,
  and `create_plug` is replaced by `Livekitex.Webhook.Plug`. Verification now checks the issuer
  and the body hash, so real LiveKit webhooks are accepted and forged ones rejected.
* **Tokens**: default TTL is now 6 hours; `room_join` without identity returns
  `{:error, :identity_required}`; grants reject unknown keys; a `room_config` with storage
  credentials or stream outputs is refused unless `allow_sensitive_credentials: true`.
* **Config**: use `url:` (`host`/`port`/`use_tls` still work); it has no default any more, so
  set it (or `LIVEKIT_URL`) explicitly. `Livekitex.Logger`, the Tesla/Finch configuration and
  `Livekitex.Application` were removed; use the `[:livekitex, :request]` telemetry events.
* **Egress** tokens now use the `roomRecord` grant required by LiveKit.

## Not supported

* Joining rooms as a participant, publishing or subscribing to media, data streams between
  participants, E2EE: these need a WebRTC client and are outside a server SDK.
* LiveKit Cloud control-plane APIs (agent deployment, replay, simulations): use the `lk` CLI.

## Development

```bash
mix test                                  # unit tests
livekit-server --dev & mix test --only integration
LIVEKIT_CLOUD_URL=... LIVEKIT_CLOUD_API_KEY=... LIVEKIT_CLOUD_API_SECRET=... mix test --only cloud
mix livekitex.gen.protos --tag v1.55.0    # regenerate protobuf modules (needs protoc)
```

## License

Apache-2.0, see [LICENSE](https://github.com/rocket4ce/livekitex/blob/main/LICENSE). The vendored protobuf definitions in `priv/protos` come from
[livekit/protocol](https://github.com/livekit/protocol) under the same license.

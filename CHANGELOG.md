# Changelog

## 0.2.1 (2026-11-24)

Hardening release from a full audit of 0.2.0. No API was removed or renamed; every change
brings the code in line with what its documentation and typespecs already promised.

### Fixed

- `TokenVerifier.verify_permissions/3` raised `Protocol.UndefinedError` for a flat
  `agent: true`, because `:agent` is both a grant group and a `VideoGrant` field. A keyword
  list is now read as groups only when every value is itself a list of permissions, so
  `verify_permissions(v, jwt, room_join: true, agent: true)` checks video permissions and
  `verify_permissions(v, jwt, agent: [admin: true])` checks the agent grant.
- `Webhook.receive_event/3` raised `ArgumentError` when no credentials were configured,
  crashing the request inside `Webhook.Plug` instead of answering. It now returns
  `{:error, :missing_credentials}` and the plug replies `401`.
- `AccessToken.to_jwt/1` signed tokens LiveKit always rejects. It now returns
  `{:error, :invalid_ttl}` for a non-positive `:ttl` (the token was expired the moment it
  was signed) and `{:error, :missing_api_key}` when there is no API key.
- `EgressService.update_stream/3` is no longer retried by default: `add_output_urls` does
  not deduplicate, so a retry after a dropped connection could report that the stream
  already exists. Pass `retry: true` for the old behaviour.
- `mix livekitex.gen.protos` deleted `lib/livekitex/proto` before running `protoc`, so a
  failing `protoc` left the repository without its generated modules. Generation now happens
  in a temporary directory and only replaces the output on success. The cloned upstream
  checkout is also removed afterwards instead of being left in the system temp directory.
- `AccessToken.put_grants/2` and the `set_*_grant/2` functions raised `FunctionClauseError`
  or `Protocol.UndefinedError` on bad input; they now raise `ArgumentError` naming the
  expected grants and types.

### Documentation

- `Livekitex.Config.get/0` and `Livekitex.config/0` warn that the returned map holds the API
  secret and, unlike `Livekitex.Client`, has no `Inspect` protection.
- The retry section of `Livekitex.Twirp` and the README no longer read as if HTTP 502/503/504
  were excluded from retries, and list `update_stream/3` among the calls that are not retried.
- `Webhook.Plug` documents `401` for an endpoint with no credentials configured.

### Internal

- New `LivekitexTest` suite covering the top-level facade (`client/1`, `access_token/2`,
  `room_join_token/3`, `admin_token/1`, `receive_webhook/3`, `config/0`, `configure/2`,
  `version/0`), which had almost no coverage.
- CI runs `mix dialyzer`; `credo` and `ex_doc` updated.

## 0.2.0 (2026-11-18)

Breaking release that brings the SDK in line with livekit/protocol **v1.54.1**.
See "Migrating from 0.1" in the README.

### Added

- `Livekitex.Client` (Req-based) shared by all services; `ws://`/`wss://` URLs, TLS and LiveKit
  Cloud work out of the box.
- `Livekitex.Twirp`: request ids (`x-livekit-request-id`), safe retries with backoff, per-call
  timeouts, `[:livekitex, :request]` telemetry spans.
- `Livekitex.Error` with Twirp `code`/`msg`/`meta` and `sip_status/1`.
- RoomService: `get_participant`, `update_participant`, `update_subscriptions`, `send_data`,
  `update_room_metadata`, `forward_participant`, `move_participant`, `perform_rpc`;
  `create_room` supports `agents`, `egress`, `tags`, `room_preset`, `replay_enabled`.
- Egress: unified `start_egress/3`.
- `Livekitex.IngressService` (create/update/list/delete).
- `Livekitex.AgentDispatchService` (create/delete/list/get).
- `Livekitex.SIPService` rewritten on `livekit_sip.proto`: inbound/outbound trunks
  (create/update/replace/get/list/delete), dispatch rules, `create_sip_participant`,
  `transfer_sip_participant`.
- Experimental, LiveKit Cloud only: `Livekitex.ConnectorService` (WhatsApp, Twilio) and
  `Livekitex.PhoneNumberService`.
- Tokens: `agent`, `inference`, `observability` grants; `kind`, `kindDetails`; video grant
  `agent`, `destination_room`, `can_subscribe_metrics`, `can_manage_agent_session`; typed
  `room_config` (agent dispatch on room creation); `put_claim/3`.
- `Livekitex.Webhook.Plug`, `Livekitex.Webhook.BodyReader`, `Livekitex.Webhook.Handler`.
- `Livekitex.TokenSource.Plug` implementing the client SDKs' token endpoint.
- `mix livekitex.gen.protos` to regenerate protobuf modules from upstream.

### Changed

- Protobuf modules regenerated from upstream (unmodified) under `Livekitex.Proto.Livekit.*`.
- All services return generated protobuf structs; list calls return lists, except paginated
  ones (`list_egress`, `list_ingress`, phone numbers) which return the response struct.
- `RoomService.list_rooms/2` takes `names:` as an option; `AgentDispatchService`
  `delete_dispatch/4` and `get_dispatch/4` take the room first.
- `:url` has no default; `Livekitex.Client.new/1` raises when it is missing.
- URLs keep their path (reverse proxies) and IPv6 hosts are supported.
- Functions with only positional request fields reject unknown options.
- Default token TTL is 6 hours; `nbf` is the issue time.
- `to_jwt/1` refuses room configs embedding storage credentials or stream outputs unless
  `allow_sensitive_credentials: true` (as the Go SDK does).
- `inspect/1` of clients, tokens and verifiers hides the API secret.
- `TokenVerifier` checks `exp`/`nbf` (with leeway) and returns atom errors.
- Minimum Elixir version is 1.16; `protobuf` 0.17.

### Fixed

- Webhooks were rejected (issuer hard-coded to `"webhook"`, `Bearer` prefix required) and the
  body hash was never checked.
- Room/Egress requests ignored TLS and always used `http://host:port`.
- Egress requests used `roomAdmin` instead of the required `roomRecord` grant.
- Server error codes were converted with `String.to_atom/1`.
- `protobuf` was a compile-time-only dependency, breaking releases.
- Token grants set to `false` (e.g. `can_publish: false`) are kept in the JWT.
- `TokenVerifier.verify_permissions/3` applies LiveKit's grant defaults and compares lists.

### Removed

- `Livekitex.Room`, `Livekitex.Participant`, `Livekitex.Track`, `*ServiceClient` and
  `*ServiceBehaviour` modules, `Livekitex.Logger`, `Livekitex.Application`, `Livekitex.TwirpUtils`.
- Tesla, Finch (direct), Mox dependencies.

# Upstream notes (livekit/protocol v1.54.1)

Compiled 2026-11-18 from raw source. Abbreviations / base URLs:

- `PROTO` = https://raw.githubusercontent.com/livekit/protocol/v1.54.1/
- `SDKGO` = https://raw.githubusercontent.com/livekit/server-sdk-go/v2.20.0/
- `SRV` = https://raw.githubusercontent.com/livekit/livekit/v1.13.11/ (latest release at time of writing, published 2026-10-25, per https://api.github.com/repos/livekit/livekit/releases)
- `NODE` = https://raw.githubusercontent.com/livekit/node-sdks/main/packages/livekit-server-sdk/src/

## 8. Git tag

`v1.54.1` exists: https://api.github.com/repos/livekit/protocol/git/ref/tags/v1.54.1 returns `"ref": "refs/tags/v1.54.1"` (annotated tag, object sha `6ab113b2590696bb347f79549fe8fd50961b123d`).

Note: .proto files live under `protobufs/` in the repo (e.g. `PROTO protobufs/livekit_room.proto`), not at the repo root.

## 1. Auth grants (`PROTO auth/grants.go`)

### JWT payload shape
`tokenClaims` embeds `jwt.RegisteredClaims` and `ClaimGrants` flat (`PROTO auth/accesstoken.go`):
```go
type tokenClaims struct {
	jwt.RegisteredClaims
	ClaimGrants
}
```
So `video`, `sip`, `kind`, ... are top-level JWT claims next to `iss`, `sub`, `nbf`, `iat`, `exp`. `iss`=API key, `sub`=identity, `iat`/`nbf`=now, `exp`=now+validFor; `defaultValidDuration = 6 * time.Hour`. Algorithm: HS256 only (`allowedSigningMethods = []string{jwt.SigningMethodHS256.Alg()}`, `PROTO auth/verifier.go`).

### ClaimGrants
```go
type ClaimGrants struct {
	Identity      string              `json:"identity,omitempty"`
	Name          string              `json:"name,omitempty"`
	Kind          string              `json:"kind,omitempty"`
	KindDetails   []string            `json:"kindDetails,omitempty"`
	Video         *VideoGrant         `json:"video,omitempty"`
	SIP           *SIPGrant           `json:"sip,omitempty"`
	Agent         *AgentGrant         `json:"agent,omitempty"`
	Inference     *InferenceGrant     `json:"inference,omitempty"`
	Observability *ObservabilityGrant `json:"observability,omitempty"`
	AgentEndpoint *AgentEndpointGrant `json:"agentEndpoint,omitempty"`
	AgentThread   *AgentThreadGrant   `json:"agentThread,omitempty"`
	AgentDatabase *AgentDatabaseGrant `json:"agentDatabase,omitempty"`
	RoomConfig *RoomConfiguration `json:"roomConfig,omitempty"`
	RoomPreset string `json:"roomPreset,omitempty"`
	Sha256   string `json:"sha256,omitempty"`
	Metadata string `json:"metadata,omitempty"`
	Attributes map[string]string `json:"attributes,omitempty"`
}
```
Key list: `identity, name, kind, kindDetails, video, sip, agent, inference, observability, agentEndpoint, agentThread, agentDatabase, roomConfig, roomPreset, sha256, metadata, attributes`. Note `identity` is also in ClaimGrants but is overwritten from `sub` on verify (`claims.ClaimGrants.Identity = v.identity`, `verifier.go`); `sub` is the canonical place.

### VideoGrant (json keys; `*bool` marked)
```go
type VideoGrant struct {
	RoomCreate bool `json:"roomCreate,omitempty"`
	RoomList   bool `json:"roomList,omitempty"`
	RoomRecord bool `json:"roomRecord,omitempty"`
	RoomAdmin bool   `json:"roomAdmin,omitempty"`
	RoomJoin  bool   `json:"roomJoin,omitempty"`
	Room      string `json:"room,omitempty"`
	CanPublish     *bool `json:"canPublish,omitempty"`
	CanSubscribe   *bool `json:"canSubscribe,omitempty"`
	CanPublishData *bool `json:"canPublishData,omitempty"`
	CanPublishSources []string `json:"canPublishSources,omitempty"`
	CanUpdateOwnMetadata *bool `json:"canUpdateOwnMetadata,omitempty"`
	IngressAdmin bool `json:"ingressAdmin,omitempty"`
	Hidden bool `json:"hidden,omitempty"`
	Recorder bool `json:"recorder,omitempty"`
	Agent bool `json:"agent,omitempty"`
	CanSubscribeMetrics *bool `json:"canSubscribeMetrics,omitempty"`
	CanManageAgentSession *bool `json:"canManageAgentSession,omitempty"`
	DestinationRoom string `json:"destinationRoom,omitempty"`
}
```
`*bool` fields: canPublish, canSubscribe, canPublishData, canUpdateOwnMetadata, canSubscribeMetrics, canManageAgentSession. Defaults when absent: canPublish=true, canSubscribe=true, canPublishData=canPublish, canUpdateOwnMetadata=false, canSubscribeMetrics=false, canManageAgentSession=false (getters in same file). `canPublishSources` is a list of lowercase strings: `sourceToString = strings.ToLower(source.String())` (e.g. `camera`, `microphone`, `screen_share`, `screen_share_audio`). Everything uses `omitempty`, so false bools are omitted; a `*bool` set to false IS emitted as `false` (non-nil pointer).

### Other grants
```go
type SIPGrant struct {
	Admin bool `json:"admin,omitempty"`
	Call  bool `json:"call,omitempty"`
}
type AgentGrant struct {
	Admin           bool `json:"admin,omitempty"`
	SimulationAdmin bool `json:"simulationAdmin,omitempty"`
	DispatchAdmin   bool `json:"dispatchAdmin,omitempty"`
}
type InferenceGrant struct {
	Perform bool `json:"perform,omitempty"`
}
type ObservabilityGrant struct {
	Write bool `json:"write,omitempty"`
}
type AgentEndpointGrant struct {
	Call       bool   `json:"call,omitempty"`
	AgentName  string `json:"agentName,omitempty"`
	Deployment string `json:"deployment,omitempty"`
}
type AgentThreadGrant struct {
	All       bool     `json:"all,omitempty"`
	Scope     string   `json:"scope,omitempty"`
	ThreadIDs []string `json:"threadIds,omitempty"`
	List      bool     `json:"list,omitempty"`
	Create    bool     `json:"create,omitempty"`
	Write     bool     `json:"write,omitempty"`
	Read      bool     `json:"read,omitempty"`
	Delete    bool     `json:"delete,omitempty"`
	SQL       bool     `json:"sql,omitempty"`
}
```
**AgentDatabaseGrant: UNVERIFIED.** Only the `AgentDatabase *AgentDatabaseGrant \`json:"agentDatabase,omitempty"\`` field was confirmed; the struct body is further down `grants.go` than I read (file is ~26 KB; I read through `AgentThreadGrant` and its `MarshalLogObject` begins). Fetch `PROTO auth/grants.go` and grep `type AgentDatabaseGrant`.

### kind / kindDetails
`Kind` is a plain `string` (not a list); `KindDetails` is `[]string`. Both are the lowercased proto enum names:
```go
func kindFromProto(source livekit.ParticipantInfo_Kind) string { return strings.ToLower(source.String()) }
func kindToProto(sourceStr string) livekit.ParticipantInfo_Kind {
	if val, ok := livekit.ParticipantInfo_Kind_value[strings.ToUpper(sourceStr)]; ok { ... }
	return livekit.ParticipantInfo_STANDARD
}
func kindDetailsFromProto(...) []string { ... strings.ToLower(d.String()) }
```
Enums (`PROTO protobufs/livekit_models.proto`):
- `ParticipantInfo.Kind`: STANDARD=0, INGRESS=1, EGRESS=2, SIP=3, AGENT=4, CONNECTOR=7, BRIDGE=8
  -> token values `"standard" "ingress" "egress" "sip" "agent" "connector" "bridge"`. Unknown string decodes to STANDARD. `standard` is normally just omitted (`omitempty`, though `SetParticipantKind(STANDARD)` would write `"standard"`).
- `ParticipantInfo.KindDetail`: CLOUD_AGENT=0, FORWARDED=1, CONNECTOR_WHATSAPP=2, CONNECTOR_TWILIO=3, BRIDGE_RTSP=4, SIMULATION=5
  -> `"cloud_agent" "forwarded" "connector_whatsapp" "connector_twilio" "bridge_rtsp" "simulation"`. Unknown entries are dropped on decode.

### roomConfig serialization
```go
type RoomConfiguration livekit.RoomConfiguration
func (c *RoomConfiguration) MarshalJSON() ([]byte, error)  { return protojson.Marshal((*livekit.RoomConfiguration)(c)) }
func (c *RoomConfiguration) UnmarshalJSON(data []byte) error { return protojson.Unmarshal(data, (*livekit.RoomConfiguration)(c)) }
```
`protojson` here is `PROTO utils/protojson/protojson.go`, a thin wrapper over `google.golang.org/protobuf/encoding/protojson` with `MarshalOptions{AllowPartial: true}` -> default options: **lowerCamelCase** JSON names (`emptyTimeout`, `departureTimeout`, `maxParticipants`, `minPlayoutDelay`, `maxPlayoutDelay`, `syncStreams`, `agents`, `egress`, `tags`), default values omitted, uint32 as JSON numbers, int64/uint64 as strings, Duration as `"1.5s"`. Unmarshal accepts both camelCase and snake_case, and discards unknown fields. RoomConfiguration proto fields (`protobufs/livekit_room.proto`): name=1, empty_timeout=2, departure_timeout=3, max_participants=4, egress=5, min_playout_delay=7, max_playout_delay=8, sync_streams=9, agents=10 (repeated RoomAgentDispatch), metadata=11, tags=12.
`ToJWT` refuses (ErrSensitiveCredentials) room configs containing S3 secret / GCP credentials / Azure account key / AliOSS secret or room stream outputs unless `allowSensitiveCredentials`.

Sources: `PROTO auth/grants.go`, `PROTO auth/accesstoken.go`, `PROTO auth/verifier.go`, `PROTO utils/protojson/protojson.go`, `PROTO protobufs/livekit_models.proto`.

## 2. Required grant per RPC

Server enforcement (`SRV pkg/service/auth.go`) helpers:
- `EnsureCreatePermission`: `video.roomCreate`
- `EnsureListPermission`: `video.roomList`
- `EnsureRecordPermission`: `video.roomRecord`
- `EnsureIngressAdminPermission`: `video.ingressAdmin`
- `EnsureSIPAdminPermission`: `sip.admin`; `EnsureSIPCallPermission`: `sip.call`
- `EnsureAdminPermission(ctx, room)`: `video.roomAdmin && req.room == video.room` (exact string equality; empty room only matches empty `video.room`)
- `EnsureDestRoomPermission(ctx, src, dst)`:
```go
if !claims.Video.RoomAdmin || source != livekit.RoomName(claims.Video.Room) || destination != livekit.RoomName(claims.Video.DestinationRoom) {
    return ErrPermissionDenied
}
```
**So yes: for ForwardParticipant and MoveParticipant the token MUST carry `video.destinationRoom` equal to the request's `destinationRoom`.** Server calls at `SRV pkg/service/roomservice.go` L367, L385.

HTTP auth: `Authorization: Bearer <jwt>` required (else 401 `invalid authorization header. Must start with Bearer `); also accepts `?access_token=` query param when no header (`SRV pkg/service/auth.go`). Go SDK sends `Authorization: Bearer <token>` (`SDKGO signalling/utils.go` `NewHTTPHeaderWithToken`), plus `X-Livekit-Request-Id: <uuid>` (`SDKGO auth.go`).

Table: RPC -> grant fields set by Go SDK (`SDKGO roomclient.go, egressclient.go, ingressclient.go, sipclient.go, agent_dispatch_client.go, connectorclient.go, phonenumberclient.go`), cross-checked with server and Node (`NODE RoomServiceClient.ts` etc.). All grants are in `video` unless prefixed `sip.`.

| Service.RPC | Go SDK grant | Server requires | Node SDK |
|---|---|---|---|
| RoomService.CreateRoom | roomCreate | roomCreate | roomCreate |
| RoomService.ListRooms | roomList | roomList | roomList |
| RoomService.DeleteRoom | roomCreate | roomCreate | roomCreate |
| RoomService.ListParticipants | roomAdmin, room=req.Room | roomAdmin + room match | same |
| RoomService.GetParticipant | roomAdmin, room | same | same |
| RoomService.RemoveParticipant | roomAdmin, room | same | same |
| RoomService.MutePublishedTrack | roomAdmin, room | same | same |
| RoomService.UpdateParticipant | roomAdmin, room | same | same |
| RoomService.UpdateSubscriptions | roomAdmin, room | same | same |
| RoomService.SendData | roomAdmin, room | same | same |
| RoomService.UpdateRoomMetadata | roomAdmin, room | same | same |
| RoomService.ForwardParticipant | roomAdmin, room, destinationRoom | roomAdmin + room + destinationRoom match | roomAdmin, room, destinationRoom |
| RoomService.MoveParticipant | roomAdmin, room, destinationRoom | roomAdmin + room + destinationRoom match | roomAdmin, room, destinationRoom |
| RoomService.PerformRpc | NOT in Go SDK roomclient.go (UNVERIFIED that no other Go client wraps it) | `EnsureAdminPermission(room)` then requires non-empty `destination_identity` (`ErrDestinationIdentityRequired`) -> roomAdmin + room | not found in Node RoomServiceClient grep (UNVERIFIED) |
| Egress.StartEgress | roomRecord | roomRecord | n/a |
| Egress.StartRoomCompositeEgress / StartWebEgress / StartParticipantEgress / StartTrackCompositeEgress / StartTrackEgress | roomRecord | roomRecord (all funnel via StartEgress launcher, `EnsureRecordPermission`) | roomRecord |
| Egress.UpdateLayout / UpdateStream / ListEgress / StopEgress | roomRecord | roomRecord | roomRecord |
| Ingress.CreateIngress / UpdateIngress / ListIngress / DeleteIngress | ingressAdmin | ingressAdmin | ingressAdmin |
| SIP.CreateSIPInboundTrunk, CreateSIPOutboundTrunk, UpdateSIPInboundTrunk, UpdateSIPOutboundTrunk, GetSIPInboundTrunk, GetSIPOutboundTrunk, ListSIPTrunk, ListSIPInboundTrunk, ListSIPOutboundTrunk, DeleteSIPTrunk, CreateSIPDispatchRule, UpdateSIPDispatchRule, ListSIPDispatchRule, DeleteSIPDispatchRule | sip.admin | sip.admin | sip.admin |
| SIP.CreateSIPParticipant | sip.call | sip.call | sip.call |
| SIP.TransferSIPParticipant | sip.call AND video roomAdmin + room=req.RoomName | sip.call AND `EnsureAdminPermission(req.room_name)` (roomAdmin + room) | sip.call + roomAdmin + room |
| AgentDispatchService.CreateDispatch / DeleteDispatch / ListDispatch | roomAdmin, room=req.Room | roomAdmin + room match | roomAdmin, room |
| Connector.ConnectTwilioCall | roomCreate, room=req.RoomName | not in livekit-server (cloud-only; UNVERIFIED server side) | roomCreate |
| Connector.DialWhatsAppCall | roomCreate, room=req.RoomName | idem | roomCreate |
| Connector.AcceptWhatsAppCall | roomCreate, room=req.RoomName | idem | roomCreate |
| Connector.ConnectWhatsAppCall | roomCreate (no room) | idem | roomCreate |
| Connector.DisconnectWhatsAppCall | roomCreate (no room) | idem | roomCreate |
| PhoneNumberService.SearchPhoneNumbers / PurchasePhoneNumber / ListPhoneNumbers / GetPhoneNumber / UpdatePhoneNumber / ReleasePhoneNumbers | sip.admin (all six) | cloud-only (UNVERIFIED server side) | no Node client found in src listing |

Other facts:
- Go SDK `GetSIPInboundTrunksByIDs` etc. are SDK helpers (sip.admin) and `AgentDispatchClient.GetDispatch` is a ListDispatch wrapper with `DispatchId`+`Room`; not separate RPCs.
- Go SDK agent (cloud agents) client `agent_client.go` uses `withAgentGrant{Admin: true}` => token claim `agent.admin`. That RPC set (CreateAgent, ListAgents, ...) is a different service not covered in Q7.
- Go `AcceptWhatsAppCall` with `WaitUntilAnswered` and SIP `CreateSIPParticipant`/`TransferSIPParticipant` extend the deadline to the ringing window (`defaultRingingTimeout`, `dialContext`, `pinRingingTimeout`); Node does the same via `dialRequestTimeout` (`NODE dialTimeout.ts`, constant `DEFAULT_RINGING_TIMEOUT_SECONDS`). Exact values UNVERIFIED (files not read).
- Node default token TTL for API calls: `'10m'` (`NODE ServiceBase.ts`). Go uses AccessToken default 6h (`defaultValidDuration`) since `prepareContext` doesn't call SetValidFor.

Source URLs: `SRV pkg/service/auth.go`, `roomservice.go`, `egress.go`, `ingress.go`, `sip.go`, `agent_dispatch_service.go`; `SDKGO` files above; `NODE RoomServiceClient.ts, EgressClient.ts, IngressClient.ts, SipClient.ts, AgentDispatchClient.ts, ConnectorClient.ts, ServiceBase.ts`.

## 3. Webhook verification (`PROTO webhook/verifier.go`, `webhook/consts.go`, `webhook/url_notifier.go`)

Sender (`url_notifier.go`):
```go
encoded, err := protojson.Marshal(event)
sum := sha256.Sum256(encoded)
b64 := base64.StdEncoding.EncodeToString(sum[:])
at := auth.NewAccessToken(params.APIKey, params.APISecret).SetValidFor(5 * time.Minute).SetSha256(b64)
...
r.Header.Set(authHeader, token)
r.Header.Set(contentTypeHeader, ContentType)
r.Header.Set(userAgentHeader, params.UserAgent)
```
`consts.go`:
```go
authHeader        = "Authorization"
contentTypeHeader = "content-type"
ContentType      = "application/webhook+json"   // "use a custom mime type to ensure signature is checked prior to parsing"
DefaultUserAgent = "LiveKit"
```
Receiver (`verifier.go`):
```go
authToken := r.Header.Get(authHeader)
if authToken == "" { return nil, ErrNoAuthHeader }
v, err := auth.ParseAPIToken(authToken)
secret := provider.GetSecret(v.APIKey())
_, claims, err := v.Verify(secret)
sha := sha256.Sum256(data)
hash := base64.StdEncoding.EncodeToString(sha[:])
if subtle.ConstantTimeCompare([]byte(claims.Sha256), []byte(hash)) != 1 { return nil, ErrInvalidChecksum }
```
- sha256: SHA-256 of the **raw request body bytes**, **standard base64 with padding** (`base64.StdEncoding`), stored in the JWT claim `sha256`, constant-time compare.
- Authorization header: the **raw JWT with no `Bearer ` prefix** (the sender sets the bare token; the Go verifier passes the header value straight to `ParseAPIToken`, which would fail on a `Bearer ` prefix. Bearer-stripping is not implemented in Go). An Elixir verifier may strip an optional `Bearer ` to be lenient (my recommendation; not upstream behavior).
- Issuer check: API key is read from the (unverified) `iss` claim, secret looked up via KeyProvider, then `Verify` uses `jwt.WithIssuer(v.apiKey)` (iss must equal the key it looked up, tautological), HS256 only, `WithLeeway(time.Minute)`, `WithExpirationRequired()` (exp mandatory). Source: `PROTO auth/verifier.go`.
- Body is parsed with protojson `DiscardUnknown: true, AllowPartial: true` into `livekit.WebhookEvent`.
- Content-Type of delivery: `application/webhook+json`. Event names (`consts.go`): room_started, room_finished, participant_joined, participant_left, participant_connection_aborted, track_published, track_unpublished, egress_started, egress_updated, egress_ended, ingress_started, ingress_ended, agent_job_pending, agent_job_started, agent_job_ended.
- Node (`NODE WebhookReceiver.ts`): `receive(body, authHeader, skipAuth, clockTolerance)`; verifies the token via `TokenVerifier.verify(authHeader, ...)`, requires claim `sha256` ("sha256 was not found in the token"), computes base64 via `btoa` of the digest bytes (std padded) of the body. Whether Node's `verify` strips `Bearer ` is UNVERIFIED (AccessToken.ts grep for "Bearer" returned nothing). Node also exports `authorizeHeader = 'Authorize'` (odd constant; the Go side uses `Authorization`).

## 4. Node TwirpRPC (`NODE TwirpRPC.ts`, `NODE failover.ts`)

- URL: `${prefix}/${pkg}.${service}/${method}`, `prefix` default `/twirp`, `pkg` = `livekit` (`livekitPackage`). Method POST, body `JSON.stringify(data)`.
- Content type actually sent: `'Content-Type': 'application/json;charset=UTF-8'`; also `'User-Agent': livekit-server-sdk-node/<version>`; plus caller headers (Authorization).
- Request-id header: `X-Livekit-Request-Id` (`REQUEST_ID_HEADER`), a random UUID generated once per logical call and reused across attempts.
- Default timeout: `defaultTimeoutSeconds = 10`; applied with `AbortSignal.timeout(timeout * 1000)`.
- Retry ("failover") policy:
  - `FAILOVER_MAX_ATTEMPTS = 3` (original + up to 2 fallback regions), `FAILOVER_BACKOFF_BASE_MS = 200`, sleep `200 * 2 ** attempt` ms (200ms, then 400ms).
  - Retried: any transport error (fetch throws, incl. timeout) or HTTP status >= 500. Not retried: any 4xx and any other non-ok status < 500 (`retryable = transportError !== undefined || (!!response && response.status >= 500)`).
  - Only engages when failover enabled (default true), host ends with `.livekit.cloud`, and per-request timeout is >= `MIN_FAILOVER_TIMEOUT_SECONDS = 5` (otherwise 1 attempt). So **self-hosted servers get exactly one attempt, no retries**.
  - Fallback regions come from `GET <origin>/settings/regions` (2s timeout, caller auth headers forwarded, `Cache-Control: max-age` honored), JSON `{"regions":[{"url":...}]}`; ws(s) URLs converted to http(s); already-attempted hosts skipped; if no untried region, error thrown.
- Success: returns raw `response.json()` (no key conversion; proto3 JSON parsers accept snake_case and camelCase).
- Errors: non-2xx -> `ServerError(statusText, msg, status, code, metadata)`. Parsed as JSON only if `content-type` header is exactly `application/json` (strict equality); fields `msg`, `code`, `meta`. Otherwise message = body text.
- Go SDK equivalents: `failoverTransport` + same header `X-Livekit-Request-Id` (`SDKGO auth.go`); detailed Go retry policy UNVERIFIED (`failover.go` not read).

## 5. TokenSource endpoint contract

Docs (https://docs.livekit.io/frontends/authentication/tokens/endpoint.md):
- Request: `POST` with JSON body, **snake_case** keys, all optional: `room_name`, `participant_identity`, `participant_name`, `room_config` (RoomConfiguration), `participant_metadata`, `participant_attributes` (map<string,string>).
- Response: **HTTP `201 Created`**, JSON `{"server_url": "...", "participant_token": "..."}` (snake_case).
- Fields the client may not set should get a 4xx.

Proto (`PROTO protobufs/livekit_token_source.proto`): `TokenSourceRequest { optional string room_name=1; participant_name=2; participant_identity=3; participant_metadata=4; map<string,string> participant_attributes=5; optional RoomConfiguration room_config=6 }`, `TokenSourceResponse { string server_url=1; string participant_token=2 }`.

Reference client (https://raw.githubusercontent.com/livekit/client-sdk-js/main/src/room/token-source/TokenSource.ts):
```ts
headers: { 'Content-Type': 'application/json', ...this.endpointOptions.headers },
body: request.toJsonString({ useProtoFieldName: true }),
...
if (!response.ok) { throw new Error(`Error generating token from endpoint ...`) }
return TokenSourceResponse.fromJson(body, { ignoreUnknownFields: true });
```
Request is sent snake_case (`useProtoFieldName: true`); the client accepts any 2xx (checks `response.ok`, not strictly 201), parses via protobuf-es `fromJson`, which accepts both snake_case and camelCase on response. Inside `room_config`, the JS client emits proto field names (snake_case, e.g. `agents[].agent_name`); a server should parse with protojson-style tolerant parsing. A reference server implementation inside livekit repos was NOT located (UNVERIFIED beyond the docs' examples).

## 6. SIP error meta keys

`PROTO livekit/sip.go`:
```go
func (p *SIPStatus) TwirpErrorMeta() map[string]string {
	status := p.Status
	if status == "" { status = p.Code.String() }
	return map[string]string{
		"sip_status_code": strconv.Itoa(int(p.Code)),
		"sip_status":      status,
	}
}
func (p *SIPTransferError) TwirpErrorMeta() map[string]string {
	m := map[string]string{ "sip_transfer_reason": p.Reason.String() }
	if p.TransferId != "" { m["sip_transfer_id"] = p.TransferId }
	// + sip_status_code / sip_status when SipStatus != nil
```
Keys: `sip_status_code` (decimal string, e.g. "486"), `sip_status` (reason phrase, or the enum name like `SIP_STATUS_BUSY_HERE` when empty), `sip_transfer_reason`, `sip_transfer_id`. They appear in the Twirp JSON error body under `meta`.
Node (`NODE SipClient.ts`, `TwirpRPC.ts`): `'sip_status_code' in e.metadata` -> `SipCallError`; getters read `metadata.sip_status_code` (Number) and `metadata.sip_status`; `describe()` also treats `error_details` as a known key to exclude. Go SDK: `SIPStatusFrom(err)` delegates to `livekit.SIPStatusFrom` (`SDKGO sipclient.go`); it reads gRPC status details rather than meta keys directly.

## 7. Twirp services (all `package livekit;`)

Twirp path = `/twirp/livekit.<Service>/<Method>`. Sources: `PROTO protobufs/livekit_*.proto`.

| Proto file | Service | RPC -> Request / Response |
|---|---|---|
| livekit_room.proto | `RoomService` | CreateRoom: CreateRoomRequest / Room; ListRooms: ListRoomsRequest / ListRoomsResponse; DeleteRoom: DeleteRoomRequest / DeleteRoomResponse; ListParticipants: ListParticipantsRequest / ListParticipantsResponse; GetParticipant: RoomParticipantIdentity / ParticipantInfo; RemoveParticipant: RoomParticipantIdentity / RemoveParticipantResponse; MutePublishedTrack: MuteRoomTrackRequest / MuteRoomTrackResponse; UpdateParticipant: UpdateParticipantRequest / ParticipantInfo; UpdateSubscriptions: UpdateSubscriptionsRequest / UpdateSubscriptionsResponse; SendData: SendDataRequest / SendDataResponse; UpdateRoomMetadata: UpdateRoomMetadataRequest / Room; ForwardParticipant: ForwardParticipantRequest / ForwardParticipantResponse; MoveParticipant: MoveParticipantRequest / MoveParticipantResponse; PerformRpc: PerformRpcRequest / PerformRpcResponse |
| livekit_egress.proto | `Egress` | StartEgress: StartEgressRequest / EgressInfo; UpdateLayout: UpdateLayoutRequest / EgressInfo; UpdateStream: UpdateStreamRequest / EgressInfo; ListEgress: ListEgressRequest / ListEgressResponse; StopEgress: StopEgressRequest / EgressInfo; StartRoomCompositeEgress: RoomCompositeEgressRequest / EgressInfo; StartWebEgress: WebEgressRequest / EgressInfo; StartParticipantEgress: ParticipantEgressRequest / EgressInfo; StartTrackCompositeEgress: TrackCompositeEgressRequest / EgressInfo; StartTrackEgress: TrackEgressRequest / EgressInfo |
| livekit_ingress.proto | `Ingress` | CreateIngress: CreateIngressRequest / IngressInfo; UpdateIngress: UpdateIngressRequest / IngressInfo; ListIngress: ListIngressRequest / ListIngressResponse; DeleteIngress: DeleteIngressRequest / IngressInfo |
| livekit_sip.proto | `SIP` | ListSIPTrunk (deprecated): ListSIPTrunkRequest / ListSIPTrunkResponse; CreateSIPInboundTrunk: CreateSIPInboundTrunkRequest / SIPInboundTrunkInfo; CreateSIPOutboundTrunk: CreateSIPOutboundTrunkRequest / SIPOutboundTrunkInfo; UpdateSIPInboundTrunk: UpdateSIPInboundTrunkRequest / SIPInboundTrunkInfo; UpdateSIPOutboundTrunk: UpdateSIPOutboundTrunkRequest / SIPOutboundTrunkInfo; GetSIPInboundTrunk: GetSIPInboundTrunkRequest / GetSIPInboundTrunkResponse; GetSIPOutboundTrunk: GetSIPOutboundTrunkRequest / GetSIPOutboundTrunkResponse; ListSIPInboundTrunk: ListSIPInboundTrunkRequest / ListSIPInboundTrunkResponse; ListSIPOutboundTrunk: ListSIPOutboundTrunkRequest / ListSIPOutboundTrunkResponse; DeleteSIPTrunk: DeleteSIPTrunkRequest / SIPTrunkInfo; CreateSIPDispatchRule: CreateSIPDispatchRuleRequest / SIPDispatchRuleInfo; UpdateSIPDispatchRule: UpdateSIPDispatchRuleRequest / SIPDispatchRuleInfo; ListSIPDispatchRule: ListSIPDispatchRuleRequest / ListSIPDispatchRuleResponse; DeleteSIPDispatchRule: DeleteSIPDispatchRuleRequest / SIPDispatchRuleInfo; CreateSIPParticipant: CreateSIPParticipantRequest / SIPParticipantInfo; TransferSIPParticipant: TransferSIPParticipantRequest / TransferSIPParticipantResponse. (CreateSIPTrunk was removed from the proto: comment `DELETED`; livekit-server still has a `CreateSIPTrunk` method, but it is not in the v1.54.1 service.) |
| livekit_agent_dispatch.proto | `AgentDispatchService` | CreateDispatch: CreateAgentDispatchRequest / AgentDispatch; DeleteDispatch: DeleteAgentDispatchRequest / AgentDispatch; ListDispatch: ListAgentDispatchRequest / ListAgentDispatchResponse |
| livekit_connector.proto | `Connector` | DialWhatsAppCall: DialWhatsAppCallRequest / DialWhatsAppCallResponse; DisconnectWhatsAppCall: DisconnectWhatsAppCallRequest / DisconnectWhatsAppCallResponse; ConnectWhatsAppCall: ConnectWhatsAppCallRequest / ConnectWhatsAppCallResponse; AcceptWhatsAppCall: AcceptWhatsAppCallRequest / AcceptWhatsAppCallResponse; ConnectTwilioCall: ConnectTwilioCallRequest / ConnectTwilioCallResponse |
| livekit_phone_number.proto | `PhoneNumberService` | SearchPhoneNumbers; PurchasePhoneNumber; ListPhoneNumbers; GetPhoneNumber; UpdatePhoneNumber; ReleasePhoneNumbers, each `<Name>Request` / `<Name>Response` (e.g. SearchPhoneNumbersRequest / SearchPhoneNumbersResponse) |

So the guesses are right: `livekit.Egress`, `livekit.Ingress`, `livekit.SIP`, `livekit.AgentDispatchService`, `livekit.Connector`, `livekit.PhoneNumberService`, `livekit.RoomService`. Node confirms the `svc` constants: `'RoomService'`, `'SIP'`, `'AgentDispatchService'`, `'Connector'`.

Message shapes worth noting:
- `ForwardParticipantRequest` / `MoveParticipantRequest`: `room=1, identity=2, destination_room=3`.
- `PerformRpcRequest`: `room=1, destination_identity=2, method=3, payload=4, response_timeout_ms=5`; response `payload=1`.
- `TransferSIPParticipantRequest`: `participant_identity=1, room_name=2, transfer_to=3, play_dialtone=4 (deprecated), headers=5, ringing_timeout=6 (Duration), dialtone=7 (SIPDialtone)`.

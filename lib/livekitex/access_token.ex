defmodule Livekitex.AccessToken do
  @moduledoc """
  Builds LiveKit access tokens (HS256 JWTs).

      token =
        Livekitex.AccessToken.create("api-key", "api-secret", identity: "alice", name: "Alice")
        |> Livekitex.AccessToken.set_video_grant(room_join: true, room: "standup")

      {:ok, jwt, _claims} = Livekitex.AccessToken.to_jwt(token)

  ## Dispatching an agent when the room is created

      token
      |> Livekitex.AccessToken.set_room_config(agents: [[agent_name: "support-agent"]])

  The default time-to-live is 6 hours, matching the official LiveKit SDKs. The token
  only needs to be valid when the participant first connects.
  """

  alias Joken.Signer

  alias Livekitex.Grants.{
    AgentGrant,
    ClaimGrant,
    InferenceGrant,
    ObservabilityGrant,
    SipGrant,
    VideoGrant
  }

  alias Livekitex.Proto.Livekit.RoomConfiguration

  @default_ttl 6 * 60 * 60

  @derive {Inspect, except: [:api_secret]}
  defstruct api_key: nil,
            api_secret: nil,
            identity: nil,
            ttl: @default_ttl,
            allow_sensitive_credentials: false,
            grants: %ClaimGrant{}

  @type t :: %__MODULE__{
          api_key: String.t(),
          api_secret: String.t(),
          identity: String.t() | nil,
          ttl: pos_integer(),
          allow_sensitive_credentials: boolean(),
          grants: ClaimGrant.t()
        }

  @kinds ~w(standard ingress egress sip agent connector bridge)

  @doc """
  Creates a new token.

  ## Options

    * `:identity` - participant identity (the `sub` claim). Required to join a room.
    * `:name` - display name
    * `:ttl` - time-to-live in seconds (default: 6 hours)
    * `:metadata` - participant metadata string
    * `:attributes` - participant attributes map
    * `:kind` - participant kind (`"agent"`, `"sip"`, ...)
    * `:allow_sensitive_credentials` - allow a `room_config` whose egress settings
      contain storage credentials or stream outputs (default `false`). Participant
      tokens are readable by clients, so keep this off for them.
  """
  @spec create(String.t(), String.t(), keyword()) :: t()
  def create(api_key, api_secret, opts \\ []) do
    %__MODULE__{
      api_key: api_key,
      api_secret: api_secret,
      identity: opts[:identity],
      ttl: opts[:ttl] || @default_ttl,
      allow_sensitive_credentials: Keyword.get(opts, :allow_sensitive_credentials, false),
      grants: %ClaimGrant{
        name: opts[:name],
        metadata: opts[:metadata],
        attributes: opts[:attributes],
        kind: opts[:kind] && normalize_kind(opts[:kind])
      }
    }
  end

  @doc "Alias of `create/3`."
  @spec new(String.t(), String.t(), keyword()) :: t()
  def new(api_key, api_secret, opts \\ []), do: create(api_key, api_secret, opts)

  @doc "Sets the room/media grant. Accepts a `VideoGrant` or a keyword list."
  def set_video_grant(token, grant), do: put_grant(token, :video, VideoGrant, grant)

  @doc "Sets the SIP grant. Accepts a `SipGrant` or a keyword list."
  def set_sip_grant(token, grant), do: put_grant(token, :sip, SipGrant, grant)

  @doc "Sets the agent grant. Accepts an `AgentGrant` or a keyword list."
  def set_agent_grant(token, grant), do: put_grant(token, :agent, AgentGrant, grant)

  @doc "Sets the inference grant. Accepts an `InferenceGrant` or a keyword list."
  def set_inference_grant(token, grant), do: put_grant(token, :inference, InferenceGrant, grant)

  @doc "Sets the observability grant. Accepts an `ObservabilityGrant` or a keyword list."
  def set_observability_grant(token, grant),
    do: put_grant(token, :observability, ObservabilityGrant, grant)

  @doc """
  Sets several grants at once.

      put_grants(token, video: [room_admin: true, room: "r"], sip: [call: true])
  """
  @spec put_grants(t(), keyword()) :: t()
  def put_grants(%__MODULE__{} = token, grants) do
    Enum.reduce(grants, token, fn
      {:video, g}, acc -> set_video_grant(acc, g)
      {:sip, g}, acc -> set_sip_grant(acc, g)
      {:agent, g}, acc -> set_agent_grant(acc, g)
      {:inference, g}, acc -> set_inference_grant(acc, g)
      {:observability, g}, acc -> set_observability_grant(acc, g)
    end)
  end

  @doc "Sets the participant identity."
  def set_identity(%__MODULE__{} = token, identity), do: %{token | identity: identity}

  @doc "Sets the participant display name."
  def set_name(token, name), do: update_claims(token, name: name)

  @doc "Sets the participant metadata."
  def set_metadata(token, metadata), do: update_claims(token, metadata: metadata)

  @doc "Sets the participant attributes."
  def set_attributes(token, attributes), do: update_claims(token, attributes: attributes)

  @doc "Sets the body hash claim (used when signing webhooks)."
  def set_sha256(token, sha256), do: update_claims(token, sha256: sha256)

  @doc "Sets the room preset name."
  def set_room_preset(token, preset), do: update_claims(token, room_preset: preset)

  @doc """
  Sets the participant kind: `:standard`, `:ingress`, `:egress`, `:sip`, `:agent`,
  `:connector` or `:bridge` (atoms or strings).
  """
  def set_kind(token, kind), do: update_claims(token, kind: normalize_kind(kind))

  @doc "Sets the participant kind details, e.g. `[\"cloud_agent\"]`."
  def set_kind_details(token, details),
    do: update_claims(token, kind_details: Enum.map(details, &to_string/1))

  @doc """
  Sets the room configuration applied if this token creates the room.

  Accepts a `Livekitex.Proto.Livekit.RoomConfiguration`, a keyword list (nested
  messages as keyword lists) or a raw camelCase map.

      set_room_config(token,
        empty_timeout: 300,
        agents: [[agent_name: "support-agent", metadata: ~s({"lang":"es"})]]
      )
  """
  def set_room_config(token, %RoomConfiguration{} = config),
    do: update_claims(token, room_config: config)

  def set_room_config(token, config) when is_list(config),
    do: set_room_config(token, Livekitex.Twirp.build(RoomConfiguration, config))

  def set_room_config(token, config) when is_map(config) or is_nil(config),
    do: update_claims(token, room_config: config)

  @doc """
  Adds an arbitrary top-level claim, for grants not modeled by this SDK yet.

      put_claim(token, "agentEndpoint", %{"call" => true, "agentName" => "support"})
  """
  def put_claim(%__MODULE__{grants: grants} = token, key, value) when is_binary(key) do
    %{token | grants: %{grants | extra: Map.put(grants.extra || %{}, key, value)}}
  end

  @doc """
  Signs the token. Returns `{:ok, jwt, claims}` or `{:error, reason}`.

  Returns `{:error, :identity_required}` when the token grants `room_join` without an
  identity.
  """
  @spec to_jwt(t()) :: {:ok, String.t(), map()} | {:error, term()}
  def to_jwt(%__MODULE__{} = token) do
    cond do
      token.api_secret in [nil, ""] ->
        {:error, :missing_api_secret}

      joins_room?(token) and token.identity in [nil, ""] ->
        {:error, :identity_required}

      not token.allow_sensitive_credentials and sensitive?(token.grants.room_config) ->
        {:error, :sensitive_credentials}

      true ->
        sign(token)
    end
  end

  defp sign(token) do
    now = System.os_time(:second)

    claims =
      token.grants
      |> ClaimGrant.to_claims()
      |> Map.merge(%{
        "iss" => token.api_key,
        "nbf" => now,
        "iat" => now,
        "exp" => now + token.ttl
      })
      |> maybe_put("sub", token.identity)

    Joken.encode_and_sign(claims, Signer.create("HS256", token.api_secret))
  end

  # Mirrors the Go SDK: room configs embedding storage credentials or stream outputs
  # must not end up in tokens handed to clients.
  @sensitive_modules [
    Livekitex.Proto.Livekit.S3Upload,
    Livekitex.Proto.Livekit.GCPUpload,
    Livekitex.Proto.Livekit.AzureBlobUpload,
    Livekitex.Proto.Livekit.AliOSSUpload,
    Livekitex.Proto.Livekit.StreamOutput
  ]
  @sensitive_keys ~w(s3 gcp azure aliOSS alioss stream streamOutputs stream_outputs)

  defp sensitive?(nil), do: false
  defp sensitive?(%RoomConfiguration{egress: nil}), do: false
  defp sensitive?(%RoomConfiguration{egress: egress}), do: contains_sensitive?(egress)
  defp sensitive?(%{} = map), do: contains_sensitive?(map["egress"] || map[:egress])

  defp contains_sensitive?(%module{}) when module in @sensitive_modules, do: true

  defp contains_sensitive?(%_{} = struct),
    do: struct |> Map.from_struct() |> Map.values() |> Enum.any?(&contains_sensitive?/1)

  defp contains_sensitive?(%{} = map) do
    Enum.any?(map, fn {key, value} ->
      (to_string(key) in @sensitive_keys and value not in [nil, [], %{}]) or
        contains_sensitive?(value)
    end)
  end

  defp contains_sensitive?(list) when is_list(list), do: Enum.any?(list, &contains_sensitive?/1)
  defp contains_sensitive?({_tag, value}), do: contains_sensitive?(value)
  defp contains_sensitive?(_), do: false

  @doc "Like `to_jwt/1` but returns only the JWT and raises on error."
  @spec to_jwt!(t()) :: String.t()
  def to_jwt!(%__MODULE__{} = token) do
    case to_jwt(token) do
      {:ok, jwt, _claims} -> jwt
      {:error, reason} -> raise ArgumentError, "failed to sign access token: #{inspect(reason)}"
    end
  end

  defp put_grant(%__MODULE__{grants: grants} = token, key, module, grant) do
    grant =
      case grant do
        %^module{} -> grant
        nil -> nil
        opts when is_list(opts) or is_map(opts) -> module.new(Enum.to_list(opts))
      end

    %{token | grants: Map.put(grants, key, grant)}
  end

  defp update_claims(%__MODULE__{grants: grants} = token, changes),
    do: %{token | grants: struct!(grants, changes)}

  defp joins_room?(%__MODULE__{grants: %ClaimGrant{video: %VideoGrant{room_join: true}}}),
    do: true

  defp joins_room?(_), do: false

  defp normalize_kind(kind) when is_atom(kind), do: normalize_kind(Atom.to_string(kind))

  defp normalize_kind(kind) when is_binary(kind) do
    kind = String.downcase(kind)

    if kind in @kinds do
      kind
    else
      raise ArgumentError,
            "unknown participant kind #{inspect(kind)}, expected one of #{inspect(@kinds)}"
    end
  end

  defp maybe_put(map, _key, nil), do: map
  defp maybe_put(map, _key, ""), do: map
  defp maybe_put(map, key, value), do: Map.put(map, key, value)
end

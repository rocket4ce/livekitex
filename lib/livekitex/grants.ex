defmodule Livekitex.Grants do
  @moduledoc """
  Grant structures embedded in LiveKit access tokens.

  Every grant struct serializes to the camelCase JSON keys used by LiveKit
  (`roomJoin`, `canPublish`, ...). Fields left as `nil` are omitted from the token,
  which lets LiveKit apply its defaults (for example `canPublish` and `canSubscribe`
  default to `true` when absent).
  """

  defmodule Codec do
    @moduledoc false

    @doc false
    # Note: `false` must be kept (e.g. `canPublish: false`), only `nil` is dropped.
    def to_map(struct, keys) do
      keys
      |> Enum.map(fn {field, json} -> {json, Map.fetch!(struct, field)} end)
      |> Enum.reject(fn {_json, value} -> is_nil(value) end)
      |> Map.new()
    end

    @doc false
    def from_map(module, map, keys) when is_map(map) do
      fields =
        keys
        |> Enum.map(fn {field, json} -> {field, fetch(map, json, field)} end)
        |> Enum.reject(fn {_field, value} -> is_nil(value) end)

      struct(module, fields)
    end

    defp fetch(map, json, field) do
      case Map.fetch(map, json) do
        {:ok, value} -> value
        :error -> Map.get(map, field, Map.get(map, Atom.to_string(field)))
      end
    end

    @doc false
    def camelize(atom) do
      [first | rest] = atom |> Atom.to_string() |> String.split("_")
      Enum.join([first | Enum.map(rest, &String.capitalize/1)])
    end
  end

  defmodule VideoGrant do
    @moduledoc """
    Room and media permissions (the `video` claim).

    ## Fields

      * `room_create`, `room_list`, `room_record`, `room_admin`, `room_join` - room permissions
      * `room` - room name the token is scoped to
      * `destination_room` - target room for `RoomService.forward_participant/4` and
        `RoomService.move_participant/4`
      * `can_publish`, `can_subscribe`, `can_publish_data` - media permissions
      * `can_publish_sources` - allowed sources, e.g. `["camera", "microphone"]`
      * `can_update_own_metadata`, `can_subscribe_metrics`, `can_manage_agent_session`
      * `ingress_admin`, `hidden`, `recorder`, `agent`
    """

    alias Livekitex.Grants.Codec

    @fields [
      :room_create,
      :room_list,
      :room_record,
      :room_admin,
      :room_join,
      :room,
      :destination_room,
      :can_publish,
      :can_subscribe,
      :can_publish_data,
      :can_publish_sources,
      :can_update_own_metadata,
      :can_subscribe_metrics,
      :can_manage_agent_session,
      :ingress_admin,
      :hidden,
      :recorder,
      :agent
    ]
    @keys Enum.map(@fields, &{&1, Codec.camelize(&1)})

    defstruct @fields

    @type t :: %__MODULE__{
            room_create: boolean() | nil,
            room_list: boolean() | nil,
            room_record: boolean() | nil,
            room_admin: boolean() | nil,
            room_join: boolean() | nil,
            room: String.t() | nil,
            destination_room: String.t() | nil,
            can_publish: boolean() | nil,
            can_subscribe: boolean() | nil,
            can_publish_data: boolean() | nil,
            can_publish_sources: [String.t()] | nil,
            can_update_own_metadata: boolean() | nil,
            can_subscribe_metrics: boolean() | nil,
            can_manage_agent_session: boolean() | nil,
            ingress_admin: boolean() | nil,
            hidden: boolean() | nil,
            recorder: boolean() | nil,
            agent: boolean() | nil
          }

    @doc """
    Creates a grant from a keyword list.

        iex> Livekitex.Grants.VideoGrant.new(room_join: true, room: "my-room")
        %Livekitex.Grants.VideoGrant{room_join: true, room: "my-room"}
    """
    def new(opts \\ []), do: struct!(__MODULE__, opts)

    @doc "Builds a grant from a decoded claim map (camelCase or snake_case keys)."
    def from_map(nil), do: nil

    def from_map(map) when is_map(map),
      do: Codec.from_map(__MODULE__, map, @keys)

    @doc "Converts the grant to its camelCase claim map."
    def to_map(%__MODULE__{} = grant) do
      grant
      |> Map.update!(:can_publish_sources, &normalize_sources/1)
      |> Codec.to_map(@keys)
    end

    defp normalize_sources(nil), do: nil

    defp normalize_sources(sources),
      do: Enum.map(sources, &(&1 |> to_string() |> String.downcase()))
  end

  defmodule SipGrant do
    @moduledoc "SIP permissions (the `sip` claim): `admin` manages trunks and rules, `call` dials."

    alias Livekitex.Grants.Codec

    @keys [admin: "admin", call: "call"]
    defstruct Keyword.keys(@keys)

    @type t :: %__MODULE__{admin: boolean() | nil, call: boolean() | nil}

    def new(opts \\ []), do: struct!(__MODULE__, opts)
    def from_map(nil), do: nil

    def from_map(map) when is_map(map),
      do: Codec.from_map(__MODULE__, map, @keys)

    def to_map(%__MODULE__{} = grant), do: Codec.to_map(grant, @keys)
  end

  defmodule AgentGrant do
    @moduledoc "Agent permissions (the `agent` claim)."

    alias Livekitex.Grants.Codec

    @keys [admin: "admin", simulation_admin: "simulationAdmin", dispatch_admin: "dispatchAdmin"]
    defstruct Keyword.keys(@keys)

    @type t :: %__MODULE__{
            admin: boolean() | nil,
            simulation_admin: boolean() | nil,
            dispatch_admin: boolean() | nil
          }

    def new(opts \\ []), do: struct!(__MODULE__, opts)
    def from_map(nil), do: nil

    def from_map(map) when is_map(map),
      do: Codec.from_map(__MODULE__, map, @keys)

    def to_map(%__MODULE__{} = grant), do: Codec.to_map(grant, @keys)
  end

  defmodule InferenceGrant do
    @moduledoc "LiveKit Inference permissions (the `inference` claim)."

    alias Livekitex.Grants.Codec

    @keys [perform: "perform"]
    defstruct Keyword.keys(@keys)

    @type t :: %__MODULE__{perform: boolean() | nil}

    def new(opts \\ []), do: struct!(__MODULE__, opts)
    def from_map(nil), do: nil

    def from_map(map) when is_map(map),
      do: Codec.from_map(__MODULE__, map, @keys)

    def to_map(%__MODULE__{} = grant), do: Codec.to_map(grant, @keys)
  end

  defmodule ObservabilityGrant do
    @moduledoc "Agent observability permissions (the `observability` claim)."

    alias Livekitex.Grants.Codec

    @keys [write: "write"]
    defstruct Keyword.keys(@keys)

    @type t :: %__MODULE__{write: boolean() | nil}

    def new(opts \\ []), do: struct!(__MODULE__, opts)
    def from_map(nil), do: nil

    def from_map(map) when is_map(map),
      do: Codec.from_map(__MODULE__, map, @keys)

    def to_map(%__MODULE__{} = grant), do: Codec.to_map(grant, @keys)
  end

  defmodule ClaimGrant do
    @moduledoc """
    All LiveKit-specific claims of an access token.

    `room_config` holds a `Livekitex.Proto.Livekit.RoomConfiguration` (serialized with
    protobuf JSON, camelCase). `extra` holds any additional claim, keyed by its JSON
    name, for grants this SDK does not model yet (e.g. `"agentEndpoint"`).
    """

    alias Livekitex.Grants.{AgentGrant, InferenceGrant, ObservabilityGrant, SipGrant, VideoGrant}
    alias Livekitex.Proto.Livekit.RoomConfiguration

    defstruct identity: nil,
              name: nil,
              kind: nil,
              kind_details: nil,
              metadata: nil,
              attributes: nil,
              sha256: nil,
              video: nil,
              sip: nil,
              agent: nil,
              inference: nil,
              observability: nil,
              room_preset: nil,
              room_config: nil,
              extra: %{}

    @type t :: %__MODULE__{
            identity: String.t() | nil,
            name: String.t() | nil,
            kind: String.t() | nil,
            kind_details: [String.t()] | nil,
            metadata: String.t() | nil,
            attributes: %{optional(String.t()) => String.t()} | nil,
            sha256: String.t() | nil,
            video: VideoGrant.t() | nil,
            sip: SipGrant.t() | nil,
            agent: AgentGrant.t() | nil,
            inference: InferenceGrant.t() | nil,
            observability: ObservabilityGrant.t() | nil,
            room_preset: String.t() | nil,
            room_config: RoomConfiguration.t() | map() | nil,
            extra: map()
          }

    @known ~w(sub iss exp nbf iat jti aud name kind kindDetails metadata attributes sha256
              video sip agent inference observability roomPreset roomConfig)

    @doc "Builds a `ClaimGrant` from decoded JWT claims."
    def from_claims(nil), do: nil

    def from_claims(claims) when is_map(claims) do
      %__MODULE__{
        identity: claims["sub"],
        name: claims["name"],
        kind: claims["kind"],
        kind_details: claims["kindDetails"],
        metadata: claims["metadata"],
        attributes: claims["attributes"],
        sha256: claims["sha256"],
        video: VideoGrant.from_map(claims["video"]),
        sip: SipGrant.from_map(claims["sip"]),
        agent: AgentGrant.from_map(claims["agent"]),
        inference: InferenceGrant.from_map(claims["inference"]),
        observability: ObservabilityGrant.from_map(claims["observability"]),
        room_preset: claims["roomPreset"],
        room_config: decode_room_config(claims["roomConfig"]),
        extra: Map.drop(claims, @known)
      }
    end

    @doc "Converts to the claim map embedded in the JWT (without registered claims)."
    def to_claims(%__MODULE__{} = grant) do
      %{
        "name" => grant.name,
        "kind" => grant.kind,
        "kindDetails" => grant.kind_details,
        "metadata" => grant.metadata,
        "attributes" => grant.attributes,
        "sha256" => grant.sha256,
        "video" => grant.video && VideoGrant.to_map(grant.video),
        "sip" => grant.sip && SipGrant.to_map(grant.sip),
        "agent" => grant.agent && AgentGrant.to_map(grant.agent),
        "inference" => grant.inference && InferenceGrant.to_map(grant.inference),
        "observability" => grant.observability && ObservabilityGrant.to_map(grant.observability),
        "roomPreset" => grant.room_preset,
        "roomConfig" => encode_room_config(grant.room_config)
      }
      |> Map.merge(grant.extra || %{})
      |> Enum.reject(fn {_k, v} -> is_nil(v) end)
      |> Map.new()
    end

    defp encode_room_config(nil), do: nil

    defp encode_room_config(%RoomConfiguration{} = config) do
      {:ok, map} = Protobuf.JSON.to_encodable(config)
      map
    end

    defp encode_room_config(map) when is_map(map), do: map

    defp decode_room_config(nil), do: nil

    defp decode_room_config(map) when is_map(map) do
      case Protobuf.JSON.from_decoded(map, RoomConfiguration) do
        {:ok, config} -> config
        {:error, _} -> map
      end
    end
  end
end

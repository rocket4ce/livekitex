defmodule Livekitex.Grants do
  @moduledoc """
  Provides grant structures for LiveKit access tokens.
  """

  defmodule VideoGrant do
    @moduledoc """
    Video-related permissions for LiveKit access tokens.
    """

    defstruct room_create: nil,
              room_join: nil,
              room_list: nil,
              room_record: nil,
              room_admin: nil,
              room: nil,
              can_publish: nil,
              can_publish_sources: nil,
              can_subscribe: nil,
              can_publish_data: nil,
              can_update_own_metadata: nil,
              hidden: nil,
              recorder: nil,
              ingress_admin: nil

    @type t :: %__MODULE__{
            room_create: boolean() | nil,
            room_join: boolean() | nil,
            room_list: boolean() | nil,
            room_record: boolean() | nil,
            room_admin: boolean() | nil,
            room: String.t() | nil,
            can_publish: boolean() | nil,
            can_publish_sources: list() | nil,
            can_subscribe: boolean() | nil,
            can_publish_data: boolean() | nil,
            can_update_own_metadata: boolean() | nil,
            hidden: boolean() | nil,
            recorder: boolean() | nil,
            ingress_admin: boolean() | nil
          }

    @doc """
    Creates a new VideoGrant with the specified permissions.

    ## Parameters

      - `opts`: A keyword list of video permissions.

    ## Examples

        iex> Livekitex.Grants.VideoGrant.new(room_join: true, can_publish: true)
        %Livekitex.Grants.VideoGrant{room_join: true, can_publish: true}
    """
    def new(opts \\ []) do
      struct(__MODULE__, opts)
    end

    @doc """
    Creates a VideoGrant from a map/hash.
    """
    def from_map(nil), do: nil

    def from_map(map) when is_map(map) do
      %__MODULE__{
        room_create: get_value(map, ["roomCreate", :room_create]),
        room_join: get_value(map, ["roomJoin", :room_join]),
        room_list: get_value(map, ["roomList", :room_list]),
        room_record: get_value(map, ["roomRecord", :room_record]),
        room_admin: get_value(map, ["roomAdmin", :room_admin]),
        room: get_value(map, ["room", :room]),
        can_publish: get_value(map, ["canPublish", :can_publish]),
        can_publish_sources: get_value(map, ["canPublishSources", :can_publish_sources]),
        can_subscribe: get_value(map, ["canSubscribe", :can_subscribe]),
        can_publish_data: get_value(map, ["canPublishData", :can_publish_data]),
        can_update_own_metadata:
          get_value(map, ["canUpdateOwnMetadata", :can_update_own_metadata]),
        hidden: get_value(map, ["hidden", :hidden]),
        recorder: get_value(map, ["recorder", :recorder]),
        ingress_admin: get_value(map, ["ingressAdmin", :ingress_admin])
      }
    end

    defp get_value(map, keys) do
      Enum.reduce_while(keys, nil, fn key, _acc ->
        if Map.has_key?(map, key) do
          {:halt, Map.get(map, key)}
        else
          {:cont, nil}
        end
      end)
    end

    @doc """
    Converts a VideoGrant to a map for JWT encoding.
    """
    def to_map(%__MODULE__{} = grant) do
      grant
      |> Map.from_struct()
      |> Enum.filter(fn {_k, v} -> v != nil end)
      |> Enum.into(%{})
      |> convert_keys_to_camel_case()
    end

    defp convert_keys_to_camel_case(map) do
      map
      |> Enum.map(fn
        {:room_create, v} -> {"roomCreate", v}
        {:room_join, v} -> {"roomJoin", v}
        {:room_list, v} -> {"roomList", v}
        {:room_record, v} -> {"roomRecord", v}
        {:room_admin, v} -> {"roomAdmin", v}
        {:can_publish, v} -> {"canPublish", v}
        {:can_publish_sources, v} -> {"canPublishSources", v}
        {:can_subscribe, v} -> {"canSubscribe", v}
        {:can_publish_data, v} -> {"canPublishData", v}
        {:can_update_own_metadata, v} -> {"canUpdateOwnMetadata", v}
        {:ingress_admin, v} -> {"ingressAdmin", v}
        {k, v} -> {to_string(k), v}
      end)
      |> Enum.into(%{})
    end
  end

  defmodule SipGrant do
    @moduledoc """
    SIP-related permissions for LiveKit access tokens.
    """

    defstruct admin: nil,
              call: nil

    @type t :: %__MODULE__{
            admin: boolean() | nil,
            call: boolean() | nil
          }

    @doc """
    Creates a new SipGrant with the specified permissions.
    """
    def new(opts \\ []) do
      struct(__MODULE__, opts)
    end

    @doc """
    Creates a SipGrant from a map/hash.
    """
    def from_map(nil), do: nil

    def from_map(map) when is_map(map) do
      %__MODULE__{
        admin: get_value(map, ["admin", :admin]),
        call: get_value(map, ["call", :call])
      }
    end

    defp get_value(map, keys) do
      Enum.reduce_while(keys, nil, fn key, _acc ->
        if Map.has_key?(map, key) do
          {:halt, Map.get(map, key)}
        else
          {:cont, nil}
        end
      end)
    end

    @doc """
    Converts a SipGrant to a map for JWT encoding.
    """
    def to_map(%__MODULE__{} = grant) do
      grant
      |> Map.from_struct()
      |> Enum.filter(fn {_k, v} -> v != nil end)
      |> Enum.into(%{})
      |> Enum.map(fn {k, v} -> {to_string(k), v} end)
      |> Enum.into(%{})
    end
  end

  defmodule ClaimGrant do
    @moduledoc """
    Complete claim grant structure containing all permissions and metadata.
    """

    defstruct identity: nil,
              name: nil,
              metadata: nil,
              sha256: nil,
              video: nil,
              sip: nil,
              attributes: nil,
              room_preset: nil,
              room_config: nil

    @type t :: %__MODULE__{
            identity: String.t() | nil,
            name: String.t() | nil,
            metadata: String.t() | nil,
            sha256: String.t() | nil,
            video: VideoGrant.t() | nil,
            sip: SipGrant.t() | nil,
            attributes: map() | nil,
            room_preset: String.t() | nil,
            room_config: map() | nil
          }

    @doc """
    Creates a ClaimGrant from a JWT claims map.
    """
    def from_claims(nil), do: nil

    def from_claims(claims) when is_map(claims) do
      %__MODULE__{
        identity: Map.get(claims, "sub"),
        name: Map.get(claims, "name"),
        metadata: Map.get(claims, "metadata"),
        sha256: Map.get(claims, "sha256"),
        attributes: Map.get(claims, "attributes"),
        room_preset: Map.get(claims, "roomPreset"),
        room_config: Map.get(claims, "roomConfig"),
        video: VideoGrant.from_map(Map.get(claims, "video")),
        sip: SipGrant.from_map(Map.get(claims, "sip"))
      }
    end

    @doc """
    Converts a ClaimGrant to a map for JWT encoding.
    """
    def to_claims(%__MODULE__{} = grant) do
      claims = %{}

      claims =
        if grant.name, do: Map.put(claims, "name", grant.name), else: claims

      claims =
        if grant.metadata, do: Map.put(claims, "metadata", grant.metadata), else: claims

      claims =
        if grant.sha256, do: Map.put(claims, "sha256", grant.sha256), else: claims

      claims =
        if grant.attributes, do: Map.put(claims, "attributes", grant.attributes), else: claims

      claims =
        if grant.room_preset, do: Map.put(claims, "roomPreset", grant.room_preset), else: claims

      claims =
        if grant.room_config, do: Map.put(claims, "roomConfig", grant.room_config), else: claims

      claims =
        if grant.video, do: Map.put(claims, "video", VideoGrant.to_map(grant.video)), else: claims

      claims =
        if grant.sip, do: Map.put(claims, "sip", SipGrant.to_map(grant.sip)), else: claims

      claims
    end
  end
end

defmodule Livekitex.AccessToken do
  @moduledoc """
  Provides functionality to create and manage LiveKit access tokens.
  """

  alias Joken.Signer
  alias Livekitex.Grants.{VideoGrant, SipGrant, ClaimGrant}

  # Default TTL: 10 minutes in seconds (following Ruby SDK pattern)
  @default_ttl 600
  @signing_algorithm "HS256"

  defstruct api_key: nil,
            api_secret: nil,
            identity: nil,
            ttl: @default_ttl,
            grants: nil

  @type t :: %__MODULE__{
          api_key: String.t(),
          api_secret: String.t(),
          identity: String.t(),
          ttl: integer(),
          grants: ClaimGrant.t()
        }

  @doc """
  Creates a new AccessToken.

  ## Parameters

    - `api_key`: The API key for your LiveKit project.
    - `api_secret`: The API secret for your LiveKit project.
    - `options`: A keyword list of options.
      - `identity`: The identity of the user.
      - `name`: The name of the user.
      - `ttl`: The time-to-live for the token in seconds. Defaults to 600 (10 minutes).
      - `metadata`: A string of metadata to associate with the user.
      - `attributes`: A map of attributes to associate with the user.

  ## Examples

      iex> Livekitex.AccessToken.create("api_key", "api_secret", identity: "user", name: "User Name")
      %Livekitex.AccessToken{
        api_key: "api_key",
        api_secret: "api_secret",
        identity: "user",
        ttl: 600,
        grants: %Livekitex.Grants.ClaimGrant{name: "User Name"}
      }
  """
  def create(api_key, api_secret, options \\ []) do
    grants = %ClaimGrant{
      name: Keyword.get(options, :name),
      metadata: Keyword.get(options, :metadata),
      attributes: Keyword.get(options, :attributes)
    }

    %__MODULE__{
      api_key: api_key,
      api_secret: api_secret,
      identity: Keyword.get(options, :identity),
      ttl: Keyword.get(options, :ttl, @default_ttl),
      grants: grants
    }
  end

  @doc """
  Sets the video grant for the access token.

  ## Parameters

    - `access_token`: The AccessToken struct.
    - `video_grant`: A VideoGrant struct or keyword list of video permissions.

  ## Examples

      iex> token = Livekitex.AccessToken.create("api_key", "api_secret", identity: "user")
      iex> video_grant = Livekitex.Grants.VideoGrant.new(room_join: true, can_publish: true)
      iex> token = Livekitex.AccessToken.set_video_grant(token, video_grant)
  """
  def set_video_grant(%__MODULE__{} = access_token, video_grant) when is_list(video_grant) do
    video_grant = VideoGrant.new(video_grant)
    set_video_grant(access_token, video_grant)
  end

  def set_video_grant(%__MODULE__{} = access_token, %VideoGrant{} = video_grant) do
    grants = %{access_token.grants | video: video_grant}
    %{access_token | grants: grants}
  end

  @doc """
  Sets the SIP grant for the access token.

  ## Parameters

    - `access_token`: The AccessToken struct.
    - `sip_grant`: A SipGrant struct or keyword list of SIP permissions.

  ## Examples

      iex> token = Livekitex.AccessToken.create("api_key", "api_secret", identity: "user")
      iex> sip_grant = Livekitex.Grants.SipGrant.new(admin: true)
      iex> token = Livekitex.AccessToken.set_sip_grant(token, sip_grant)
  """
  def set_sip_grant(%__MODULE__{} = access_token, sip_grant) when is_list(sip_grant) do
    sip_grant = SipGrant.new(sip_grant)
    set_sip_grant(access_token, sip_grant)
  end

  def set_sip_grant(%__MODULE__{} = access_token, %SipGrant{} = sip_grant) do
    grants = %{access_token.grants | sip: sip_grant}
    %{access_token | grants: grants}
  end

  @doc """
  Sets metadata for the access token.

  ## Parameters

    - `access_token`: The AccessToken struct.
    - `metadata`: A string of metadata to associate with the user.
  """
  def set_metadata(%__MODULE__{} = access_token, metadata) do
    grants = %{access_token.grants | metadata: metadata}
    %{access_token | grants: grants}
  end

  @doc """
  Sets attributes for the access token.

  ## Parameters

    - `access_token`: The AccessToken struct.
    - `attributes`: A map of attributes to associate with the user.
  """
  def set_attributes(%__MODULE__{} = access_token, attributes) do
    grants = %{access_token.grants | attributes: attributes}
    %{access_token | grants: grants}
  end

  @doc """
  Sets the name for the access token.

  ## Parameters

    - `access_token`: The AccessToken struct.
    - `name`: The name of the user.
  """
  def set_name(%__MODULE__{} = access_token, name) do
    grants = %{access_token.grants | name: name}
    %{access_token | grants: grants}
  end

  @doc """
  Sets the SHA256 hash for the access token.

  ## Parameters

    - `access_token`: The AccessToken struct.
    - `sha256`: The SHA256 hash string.
  """
  def set_sha256(%__MODULE__{} = access_token, sha256) do
    grants = %{access_token.grants | sha256: sha256}
    %{access_token | grants: grants}
  end

  @doc """
  Sets room configuration for the access token.

  ## Parameters

    - `access_token`: The AccessToken struct.
    - `room_config`: A map representing room configuration.
  """
  def set_room_config(%__MODULE__{} = access_token, room_config) do
    grants = %{access_token.grants | room_config: room_config}
    %{access_token | grants: grants}
  end

  @doc """
  Sets room preset for the access token.

  ## Parameters

    - `access_token`: The AccessToken struct.
    - `room_preset`: A string representing the room preset.
  """
  def set_room_preset(%__MODULE__{} = access_token, room_preset) do
    grants = %{access_token.grants | room_preset: room_preset}
    %{access_token | grants: grants}
  end

  @doc """
  Generates a JWT token from an AccessToken.

  ## Examples

      iex> token = Livekitex.AccessToken.create("devkey", "secret", identity: "user", name: "User Name")
      iex> video_grant = Livekitex.Grants.VideoGrant.new(room_join: true)
      iex> token = Livekitex.AccessToken.set_video_grant(token, video_grant)
      iex> {:ok, jwt, _claims} = Livekitex.AccessToken.to_jwt(token)
      iex> is_binary(jwt)
      true
  """
  def to_jwt(%__MODULE__{} = access_token) do
    # Validate that we have at least video or sip grants
    if is_nil(access_token.grants.video) and is_nil(access_token.grants.sip) do
      {:error, "VideoGrant or SipGrant is required"}
    else
      jwt_timestamp = System.os_time(:second)

      # Build base claims
      claims = %{
        "exp" => jwt_timestamp + access_token.ttl,
        # 5 seconds before current time
        "nbf" => jwt_timestamp - 5,
        "iss" => access_token.api_key,
        "sub" => access_token.identity,
        "iat" => jwt_timestamp
      }

      # Add grants claims
      grant_claims = ClaimGrant.to_claims(access_token.grants)
      claims = Map.merge(claims, grant_claims)

      # Remove nil values
      claims = Enum.reject(claims, fn {_k, v} -> is_nil(v) end) |> Enum.into(%{})

      signer = Signer.create(@signing_algorithm, access_token.api_secret)
      Joken.encode_and_sign(claims, signer)
    end
  end

  @doc """
  Generates a JWT token from an AccessToken, raising on error.

  ## Examples

      iex> token = Livekitex.AccessToken.create("devkey", "secret", identity: "user")
      iex> video_grant = Livekitex.Grants.VideoGrant.new(room_join: true)
      iex> token = Livekitex.AccessToken.set_video_grant(token, video_grant)
      iex> jwt = Livekitex.AccessToken.to_jwt!(token)
      iex> is_binary(jwt)
      true
  """
  def to_jwt!(%__MODULE__{} = access_token) do
    case to_jwt(access_token) do
      {:ok, jwt, _claims} -> jwt
      {:error, reason} -> raise "Failed to generate JWT: #{reason}"
    end
  end
end

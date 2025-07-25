defmodule Livekitex.AccessToken do
  @moduledoc """
  Provides functionality to create and manage LiveKit access tokens.
  """

  alias Joken.Signer
  

  defstruct api_key: nil,
            api_secret: nil,
            identity: nil,
            name: nil,
            ttl: 7200, # 2 hours
            metadata: nil,
            video: %{}

  @type t :: %__MODULE__{
          api_key: String.t(),
          api_secret: String.t(),
          identity: String.t(),
          name: String.t() | nil,
          ttl: integer(),
          metadata: String.t() | nil,
          video: map()
        }

  @doc """
  Creates a new AccessToken.

  ## Parameters

    - `api_key`: The API key for your LiveKit project.
    - `api_secret`: The API secret for your LiveKit project.
    - `options`: A keyword list of options.
      - `identity`: The identity of the user.
      - `name`: The name of the user.
      - `ttl`: The time-to-live for the token in seconds. Defaults to 7200 (2 hours).
      - `metadata`: A string of metadata to associate with the user.
      - `video`: A map of video grants.

  ## Examples

      iex> Livekitex.AccessToken.create("api_key", "api_secret", identity: "user", name: "User Name")
      %Livekitex.AccessToken{
        api_key: "api_key",
        api_secret: "api_secret",
        identity: "user",
        name: "User Name",
        ttl: 7200,
        metadata: nil,
        video: %{}
      }
  """
  def create(api_key, api_secret, options \\ []) do
    %__MODULE__{
      api_key: api_key,
      api_secret: api_secret,
      identity: Keyword.get(options, :identity),
      name: Keyword.get(options, :name),
      ttl: Keyword.get(options, :ttl, 7200),
      metadata: Keyword.get(options, :metadata),
      video: Keyword.get(options, :video, %{})
    }
  end

  @doc """
  Generates a JWT token from an AccessToken.

  ## Examples

      iex> token = Livekitex.AccessToken.create("devkey", "secret", identity: "user", name: "User Name")
      iex> {:ok, jwt, _claims} = Livekitex.AccessToken.to_jwt(token)
      iex> is_binary(jwt)
      true
  """
  def to_jwt(%__MODULE__{} = access_token) do
    claims = %{
      "exp" => System.os_time(:second) + access_token.ttl,
      "iss" => access_token.api_key,
      "sub" => access_token.identity,
      "nbf" => System.os_time(:second),
      "iat" => System.os_time(:second),
      "jti" => access_token.identity,
      "video" => access_token.video,
      "name" => access_token.name,
      "metadata" => access_token.metadata
    }

    signer = Signer.create("HS256", access_token.api_secret)

    Joken.encode_and_sign(claims, signer)
  end
end

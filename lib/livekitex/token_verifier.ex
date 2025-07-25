defmodule Livekitex.TokenVerifier do
  @moduledoc """
  Provides functionality to verify and validate LiveKit access tokens.
  """

  alias Joken.Signer
  alias Livekitex.Grants.ClaimGrant

  defstruct api_key: nil,
            api_secret: nil

  @type t :: %__MODULE__{
          api_key: String.t(),
          api_secret: String.t()
        }

  @doc """
  Creates a new TokenVerifier.

  ## Parameters

    - `api_key`: The API key for your LiveKit project.
    - `api_secret`: The API secret for your LiveKit project.

  ## Examples

      iex> Livekitex.TokenVerifier.new("api_key", "api_secret")
      %Livekitex.TokenVerifier{api_key: "api_key", api_secret: "api_secret"}
  """
  def new(api_key, api_secret) do
    %__MODULE__{
      api_key: api_key,
      api_secret: api_secret
    }
  end

  @doc """
  Verifies a JWT token and returns the claims.

  ## Parameters

    - `verifier`: A TokenVerifier struct.
    - `token`: The JWT token string to verify.

  ## Returns

    - `{:ok, claim_grant}` on successful verification.
    - `{:error, reason}` on verification failure.

  ## Examples

      iex> verifier = Livekitex.TokenVerifier.new("devkey", "secret")
      iex> {:ok, claims} = Livekitex.TokenVerifier.verify(verifier, valid_token)
      iex> claims.identity
      "user"
  """
  def verify(%__MODULE__{} = verifier, token) when is_binary(token) do
    signer = Signer.create("HS256", verifier.api_secret)

    case Joken.verify(token, signer) do
      {:ok, claims} ->
        case validate_issuer(claims, verifier.api_key) do
          :ok ->
            claim_grant = ClaimGrant.from_claims(claims)
            {:ok, claim_grant}

          {:error, reason} ->
            {:error, reason}
        end

      {:error, reason} ->
        {:error, reason}
    end
  end

  @doc """
  Verifies a JWT token and returns the claims, raising on error.

  ## Parameters

    - `verifier`: A TokenVerifier struct.
    - `token`: The JWT token string to verify.

  ## Returns

    - `claim_grant` on successful verification.
    - Raises an exception on verification failure.

  ## Examples

      iex> verifier = Livekitex.TokenVerifier.new("devkey", "secret")
      iex> claims = Livekitex.TokenVerifier.verify!(verifier, valid_token)
      iex> claims.identity
      "user"
  """
  def verify!(%__MODULE__{} = verifier, token) do
    case verify(verifier, token) do
      {:ok, claims} -> claims
      {:error, reason} -> raise "Token verification failed: #{inspect(reason)}"
    end
  end

  @doc """
  Validates token claims without signature verification.
  Useful for inspecting token contents.

  ## Parameters

    - `token`: The JWT token string to decode.

  ## Returns

    - `{:ok, claim_grant}` on successful decoding.
    - `{:error, reason}` on decoding failure.

  ## Examples

      iex> {:ok, claims} = Livekitex.TokenVerifier.decode_claims(token)
      iex> claims.identity
      "user"
  """
  def decode_claims(token) when is_binary(token) do
    try do
      case Joken.peek_claims(token) do
        {:ok, claims} ->
          claim_grant = ClaimGrant.from_claims(claims)
          {:ok, claim_grant}

        {:error, reason} ->
          {:error, reason}
      end
    rescue
      error ->
        {:error, error}
    end
  end

  @doc """
  Validates specific permissions in a token.

  ## Parameters

    - `verifier`: A TokenVerifier struct.
    - `token`: The JWT token string to verify.
    - `permissions`: A keyword list of required permissions.

  ## Returns

    - `{:ok, claim_grant}` if token is valid and has required permissions.
    - `{:error, reason}` if verification fails or permissions are insufficient.

  ## Examples

      iex> verifier = Livekitex.TokenVerifier.new("devkey", "secret")
      iex> {:ok, claims} = Livekitex.TokenVerifier.verify_permissions(verifier, token, room_join: true)
  """
  def verify_permissions(%__MODULE__{} = verifier, token, required_permissions) do
    case verify(verifier, token) do
      {:ok, claim_grant} ->
        case validate_permissions(claim_grant, required_permissions) do
          :ok -> {:ok, claim_grant}
          {:error, reason} -> {:error, reason}
        end

      {:error, reason} ->
        {:error, reason}
    end
  end

  # Private functions

  defp validate_issuer(claims, expected_api_key) do
    case Map.get(claims, "iss") do
      ^expected_api_key ->
        :ok

      actual_issuer ->
        {:error, "Invalid issuer. Expected: #{expected_api_key}, got: #{actual_issuer}"}
    end
  end

  defp validate_permissions(claim_grant, required_permissions) do
    video_grant = claim_grant.video

    if video_grant do
      validate_video_permissions(video_grant, required_permissions)
    else
      {:error, "No video grant found in token"}
    end
  end

  defp validate_video_permissions(video_grant, required_permissions) do
    missing_permissions =
      Enum.filter(required_permissions, fn {permission, required_value} ->
        actual_value = Map.get(video_grant, permission)
        not permission_satisfied?(actual_value, required_value)
      end)

    case missing_permissions do
      [] -> :ok
      missing -> {:error, "Missing required permissions: #{inspect(missing)}"}
    end
  end

  defp permission_satisfied?(nil, true), do: false
  defp permission_satisfied?(false, true), do: false
  defp permission_satisfied?(true, true), do: true
  defp permission_satisfied?(actual, required) when actual == required, do: true
  defp permission_satisfied?(_actual, _required), do: false
end

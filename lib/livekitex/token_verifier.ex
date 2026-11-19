defmodule Livekitex.TokenVerifier do
  @moduledoc """
  Verifies LiveKit access tokens: HS256 signature, issuer (the API key) and the
  `exp` / `nbf` time window.

      verifier = Livekitex.TokenVerifier.new("api-key", "api-secret")
      {:ok, %Livekitex.Grants.ClaimGrant{identity: "alice"}} =
        Livekitex.TokenVerifier.verify(verifier, jwt)

  Errors are atoms: `:invalid_token`, `:invalid_signature`, `:invalid_issuer`,
  `:missing_expiration`, `:token_expired`, `:token_not_yet_valid`.
  """

  alias Joken.Signer
  alias Livekitex.Grants.ClaimGrant

  @derive {Inspect, except: [:api_secret]}
  defstruct api_key: nil, api_secret: nil, leeway: 60

  @type t :: %__MODULE__{api_key: String.t(), api_secret: String.t(), leeway: non_neg_integer()}

  @groups [:video, :sip, :agent, :inference, :observability]

  @type error ::
          :invalid_token
          | :invalid_signature
          | :invalid_issuer
          | :missing_expiration
          | :token_expired
          | :token_not_yet_valid

  @doc """
  Creates a verifier. `:leeway` (seconds, default 60) tolerates clock skew.

      iex> Livekitex.TokenVerifier.new("api_key", "api_secret")
      %Livekitex.TokenVerifier{api_key: "api_key", api_secret: "api_secret", leeway: 60}
  """
  def new(api_key, api_secret, opts \\ []) do
    %__MODULE__{api_key: api_key, api_secret: api_secret, leeway: Keyword.get(opts, :leeway, 60)}
  end

  @doc "Verifies a token and returns its claims as a `ClaimGrant`."
  @spec verify(t(), String.t()) :: {:ok, ClaimGrant.t()} | {:error, error()}
  def verify(%__MODULE__{} = verifier, token) when is_binary(token) do
    with {:ok, claims} <- verify_raw(verifier, token) do
      parse_claims(claims)
    end
  end

  def verify(%__MODULE__{}, _token), do: {:error, :invalid_token}

  @doc """
  Verifies a token and returns the raw claim map (string keys).
  """
  @spec verify_raw(t(), String.t()) :: {:ok, map()} | {:error, error()}
  def verify_raw(%__MODULE__{} = verifier, token) when is_binary(token) do
    signer = Signer.create("HS256", verifier.api_secret)

    with {:ok, claims} <- verify_signature(token, signer),
         :ok <- check_issuer(claims, verifier.api_key),
         :ok <- check_time(claims, System.os_time(:second), verifier.leeway) do
      {:ok, claims}
    end
  end

  @doc "Like `verify/2` but raises `ArgumentError` on failure."
  def verify!(%__MODULE__{} = verifier, token) do
    case verify(verifier, token) do
      {:ok, claims} -> claims
      {:error, reason} -> raise ArgumentError, "token verification failed: #{inspect(reason)}"
    end
  end

  @doc """
  Decodes the claims **without** verifying the signature. Only use this to inspect
  tokens you already trust.
  """
  @spec decode_claims(String.t()) :: {:ok, ClaimGrant.t()} | {:error, :invalid_token}
  def decode_claims(token) when is_binary(token) do
    case Joken.peek_claims(token) do
      {:ok, claims} -> parse_claims(claims)
      {:error, _} -> {:error, :invalid_token}
    end
  rescue
    _ -> {:error, :invalid_token}
  end

  @doc """
  Verifies a token and checks that it carries the required grants.

      verify_permissions(verifier, jwt, video: [room_join: true, room: "r"], sip: [call: true])

  A flat keyword list is treated as video permissions:

      verify_permissions(verifier, jwt, room_join: true)

  Omitted video permissions use LiveKit's defaults (`can_publish` and
  `can_subscribe` default to `true`, `can_publish_data` follows `can_publish`,
  everything else is `false`). List values such as `can_publish_sources` are compared
  as sets.
  """
  @spec verify_permissions(t(), String.t(), keyword()) ::
          {:ok, ClaimGrant.t()} | {:error, error() | {:missing_permissions, keyword()}}
  def verify_permissions(%__MODULE__{} = verifier, token, required) do
    required =
      if Enum.all?(required, fn {key, _} -> key in @groups end),
        do: required,
        else: [video: required]

    with {:ok, grant} <- verify(verifier, token) do
      missing =
        for {group, perms} <- required,
            {perm, expected} <- perms,
            effective(group, Map.get(grant, group), perm) != normalize(expected),
            do: {group, {perm, expected}}

      if missing == [], do: {:ok, grant}, else: {:error, {:missing_permissions, missing}}
    end
  end

  # LiveKit defaults for omitted video permissions.
  defp effective(:video, nil, perm), do: effective(:video, %Livekitex.Grants.VideoGrant{}, perm)

  defp effective(:video, grant, perm) do
    case {perm, Map.get(grant, perm)} do
      {:can_publish, nil} -> true
      {:can_subscribe, nil} -> true
      {:can_publish_data, nil} -> effective(:video, grant, :can_publish)
      {_perm, value} -> normalize(value)
    end
  end

  defp effective(_group, nil, _perm), do: false
  defp effective(_group, grant, perm), do: grant |> Map.get(perm) |> normalize()

  defp normalize(nil), do: false

  defp normalize(sources) when is_list(sources),
    do: sources |> Enum.map(&(&1 |> to_string() |> String.downcase())) |> Enum.sort()

  defp normalize(value), do: value

  defp parse_claims(claims) do
    {:ok, ClaimGrant.from_claims(claims)}
  rescue
    _ -> {:error, :invalid_token}
  end

  defp verify_signature(token, signer) do
    if length(String.split(token, ".")) == 3 do
      do_verify_signature(token, signer)
    else
      {:error, :invalid_token}
    end
  end

  defp do_verify_signature(token, signer) do
    case Joken.verify(token, signer) do
      {:ok, claims} -> {:ok, claims}
      {:error, :signature_error} -> {:error, :invalid_signature}
      {:error, _} -> {:error, :invalid_token}
    end
  rescue
    _ -> {:error, :invalid_token}
  end

  defp check_issuer(%{"iss" => iss}, api_key) when is_binary(iss) and iss == api_key, do: :ok
  defp check_issuer(_claims, _api_key), do: {:error, :invalid_issuer}

  defp check_time(claims, now, leeway) do
    cond do
      not is_integer(claims["exp"]) -> {:error, :missing_expiration}
      now > claims["exp"] + leeway -> {:error, :token_expired}
      is_integer(claims["nbf"]) and now + leeway < claims["nbf"] -> {:error, :token_not_yet_valid}
      true -> :ok
    end
  end
end

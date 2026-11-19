defmodule Livekitex.Webhook do
  @moduledoc """
  Verifies and decodes LiveKit webhooks.

  LiveKit sends each event as a `POST` with `Content-Type: application/webhook+json`
  and an `Authorization` header holding a JWT signed with your API secret. The token's
  `sha256` claim is the base64 SHA-256 of the raw request body. This module checks the
  signature, the issuer (your API key), the expiry, and the body hash, then decodes the
  body into a `Livekitex.Proto.Livekit.WebhookEvent`.

      {:ok, event} = Livekitex.Webhook.receive_event(raw_body, auth_header)
      event.event #=> "participant_joined"

  > #### Use the raw body {: .info}
  >
  > The hash is computed over the exact bytes LiveKit sent. If `Plug.Parsers` runs
  > first (it parses `application/webhook+json` as JSON), use
  > `Livekitex.Webhook.BodyReader` or `Livekitex.Webhook.Plug`.

  ## Events

  `room_started`, `room_finished`, `participant_joined`, `participant_left`,
  `participant_connection_aborted`, `track_published`, `track_unpublished`,
  `egress_started`, `egress_updated`, `egress_ended`, `ingress_started`,
  `ingress_ended`, `agent_job_pending`, `agent_job_started`, `agent_job_ended`.
  """

  alias Livekitex.{Config, TokenVerifier}
  alias Livekitex.Proto.Livekit.WebhookEvent

  @events ~w(room_started room_finished participant_joined participant_left
             participant_connection_aborted track_published track_unpublished
             egress_started egress_updated egress_ended ingress_started ingress_ended
             agent_job_pending agent_job_started agent_job_ended)

  @type error ::
          :missing_auth_header
          | :invalid_issuer
          | :missing_sha256
          | :hash_mismatch
          | {:invalid_body, term()}
          | TokenVerifier.error()

  @doc "Known webhook event names."
  @spec events() :: [String.t()]
  def events, do: @events

  @doc """
  Verifies a webhook and decodes its event.

  ## Options

    * `:api_key`, `:api_secret` - credentials (default: `Livekitex.Config`)
    * `:keys` - a map (or list of pairs) of `api_key => api_secret` when several keys
      may sign webhooks
    * `:leeway` - clock skew tolerance in seconds (default 60)
    * `:skip_auth` - only decode, without verifying. Never use this in production.
  """
  @spec receive_event(binary(), String.t() | nil, keyword()) ::
          {:ok, WebhookEvent.t()} | {:error, error()}
  def receive_event(body, auth_header, opts \\ []) when is_binary(body) do
    with :ok <- maybe_verify(body, auth_header, opts) do
      decode_event(body)
    end
  end

  @doc """
  Verifies the `Authorization` header against the raw body without decoding it.
  Returns the verified JWT claims.
  """
  @spec verify(binary(), String.t() | nil, keyword()) :: {:ok, map()} | {:error, error()}
  def verify(body, auth_header, opts \\ [])

  def verify(_body, auth_header, _opts) when auth_header in [nil, ""],
    do: {:error, :missing_auth_header}

  def verify(body, auth_header, opts) when is_binary(body) and is_binary(auth_header) do
    token = strip_bearer(auth_header)

    with {:ok, api_key, api_secret} <- credentials(token, opts),
         verifier = TokenVerifier.new(api_key, api_secret, leeway: Keyword.get(opts, :leeway, 60)),
         {:ok, claims} <- TokenVerifier.verify_raw(verifier, token),
         :ok <- check_hash(body, claims["sha256"]) do
      {:ok, claims}
    end
  end

  @doc "Decodes a webhook body into a `WebhookEvent` without verifying it."
  @spec decode_event(binary()) :: {:ok, WebhookEvent.t()} | {:error, {:invalid_body, term()}}
  def decode_event(body) when is_binary(body) do
    case Protobuf.JSON.decode(body, WebhookEvent, ignore_unknown_fields: true) do
      {:ok, event} -> {:ok, event}
      {:error, error} -> {:error, {:invalid_body, error}}
    end
  end

  defp maybe_verify(body, auth_header, opts) do
    if opts[:skip_auth] do
      :ok
    else
      with {:ok, _claims} <- verify(body, auth_header, opts), do: :ok
    end
  end

  defp strip_bearer(header) do
    header = String.trim(header)

    case header do
      <<prefix::binary-size(7), token::binary>> ->
        if String.downcase(prefix) == "bearer ", do: String.trim(token), else: header

      _ ->
        header
    end
  end

  defp credentials(token, opts) do
    case opts[:keys] && Map.new(opts[:keys]) do
      keys when is_map(keys) ->
        with {:ok, %{"iss" => iss}} when is_binary(iss) <- peek(token),
             {:ok, secret} <- Map.fetch(keys, iss) do
          {:ok, iss, secret}
        else
          _ -> {:error, :invalid_issuer}
        end

      nil ->
        api_key = opts[:api_key] || Config.get(:api_key)
        api_secret = opts[:api_secret] || Config.get(:api_secret)

        if api_key in [nil, ""] or api_secret in [nil, ""] do
          raise ArgumentError, "LiveKit api_key and api_secret are required to verify webhooks"
        end

        {:ok, api_key, api_secret}
    end
  end

  defp peek(token) do
    Joken.peek_claims(token)
  rescue
    _ -> {:error, :invalid_token}
  end

  defp check_hash(_body, claim) when claim in [nil, ""], do: {:error, :missing_sha256}

  defp check_hash(body, claim) when is_binary(claim) do
    expected = :crypto.hash(:sha256, body)

    case Base.decode64(claim, padding: false) do
      {:ok, actual} when byte_size(actual) == 32 ->
        if Plug.Crypto.secure_compare(actual, expected), do: :ok, else: {:error, :hash_mismatch}

      _ ->
        {:error, :hash_mismatch}
    end
  end

  defp check_hash(_body, _claim), do: {:error, :hash_mismatch}
end

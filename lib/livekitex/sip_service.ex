defmodule Livekitex.SIPService do
  @moduledoc """
  High-level SIP wrapper over LiveKit's SIP Twirp API.

  Provides helpers to manage trunks, dispatch rules, and participants using
  JSON Twirp endpoints over HTTP(S) with Tesla/Finch, and token grants.
  """

  alias Livekitex.AccessToken
  alias Livekitex.Grants
  alias Livekitex.TwirpUtils
  alias Livekitex.SIPServiceClient, as: Client

  defstruct api_key: nil,
            api_secret: nil,
            base_url: nil,
            client: nil

  @type t :: %__MODULE__{
          api_key: String.t(),
          api_secret: String.t(),
          base_url: String.t(),
          client: Tesla.Client.t() | nil
        }

  @doc """
  Create a new SIPService configured for a LiveKit server.

  Options:
    - :host - e.g. "test-abc.livekit.cloud"
    - :port - integer port; default 443 for https
    - :scheme - "https" or "http"; default "https"
    - :base_url - override full base URL, e.g. "https://host:443"
  """
  def create(api_key, api_secret, opts \\ []) do
    base_url =
      Keyword.get_lazy(opts, :base_url, fn ->
        host = Keyword.get(opts, :host, "localhost")
        port = Keyword.get(opts, :port)
        scheme = Keyword.get(opts, :scheme, default_scheme(port))

        case port do
          nil -> "#{scheme}://#{host}"
          _ -> "#{scheme}://#{host}:#{port}"
        end
      end)

    %__MODULE__{api_key: api_key, api_secret: api_secret, base_url: base_url}
  end

  defp default_scheme(443), do: "https"
  defp default_scheme(nil), do: "https"
  defp default_scheme(_), do: "http"

  # --- token helpers ---
  defp admin_token(%__MODULE__{api_key: key, api_secret: secret}) do
    sip_grant = %Grants.SipGrant{admin: true}
    grants = %Grants.ClaimGrant{sip: sip_grant}

    key
    |> AccessToken.create(secret, [])
    |> Map.put(:grants, grants)
    |> AccessToken.to_jwt()
    |> case do
      {:ok, jwt, _} -> {:ok, jwt}
      error -> error
    end
  end

  defp call_token(%__MODULE__{api_key: key, api_secret: secret}) do
    sip_grant = %Grants.SipGrant{call: true}
    grants = %Grants.ClaimGrant{sip: sip_grant}

    key
    |> AccessToken.create(secret, [])
    |> Map.put(:grants, grants)
    |> AccessToken.to_jwt()
    |> case do
      {:ok, jwt, _} -> {:ok, jwt}
      error -> error
    end
  end

  # --- client helper ---
  defp ensure_client(%__MODULE__{client: nil} = svc) do
    # Allow adapter override for tests via application env
    adapter = Application.get_env(:livekitex, :tesla_adapter)
    {:ok, TwirpUtils.create_client(svc.base_url, nil, adapter: adapter)}
  end

  defp ensure_client(%__MODULE__{client: client}), do: {:ok, client}

  # --- trunks ---
  def create_inbound_trunk(%__MODULE__{} = svc, trunk \\ %{}) do
    with {:ok, client} <- ensure_client(svc),
         {:ok, token} <- admin_token(svc),
         {:ok, trunk_info} <- Client.create_inbound_trunk(client, token, trunk) do
      {:ok, trunk_info}
    else
      error -> TwirpUtils.handle_twirp_response(error)
    end
  end

  def update_inbound_trunk(%__MODULE__{} = svc, trunk_id, action) do
    with {:ok, client} <- ensure_client(svc),
         {:ok, token} <- admin_token(svc),
         {:ok, trunk_info} <- Client.update_inbound_trunk(client, token, trunk_id, action) do
      {:ok, trunk_info}
    else
      error -> TwirpUtils.handle_twirp_response(error)
    end
  end

  def get_inbound_trunk(%__MODULE__{} = svc, trunk_id) do
    with {:ok, client} <- ensure_client(svc),
         {:ok, token} <- admin_token(svc),
         {:ok, %{"trunk" => trunk_info}} <- Client.get_inbound_trunk(client, token, trunk_id) do
      {:ok, trunk_info}
    else
      error -> TwirpUtils.handle_twirp_response(error)
    end
  end

  def list_inbound_trunks(%__MODULE__{} = svc, opts \\ %{}) do
    with {:ok, client} <- ensure_client(svc),
         {:ok, token} <- admin_token(svc),
         {:ok, %{"items" => items}} <- Client.list_inbound_trunks(client, token, opts) do
      {:ok, items}
    else
      error -> TwirpUtils.handle_twirp_response(error)
    end
  end

  def create_outbound_trunk(%__MODULE__{} = svc, trunk \\ %{}) do
    with {:ok, client} <- ensure_client(svc),
         {:ok, token} <- admin_token(svc),
         {:ok, trunk_info} <- Client.create_outbound_trunk(client, token, trunk) do
      {:ok, trunk_info}
    else
      error -> TwirpUtils.handle_twirp_response(error)
    end
  end

  def update_outbound_trunk(%__MODULE__{} = svc, trunk_id, action) do
    with {:ok, client} <- ensure_client(svc),
         {:ok, token} <- admin_token(svc),
         {:ok, trunk_info} <- Client.update_outbound_trunk(client, token, trunk_id, action) do
      {:ok, trunk_info}
    else
      error -> TwirpUtils.handle_twirp_response(error)
    end
  end

  def get_outbound_trunk(%__MODULE__{} = svc, trunk_id) do
    with {:ok, client} <- ensure_client(svc),
         {:ok, token} <- admin_token(svc),
         {:ok, %{"trunk" => trunk_info}} <- Client.get_outbound_trunk(client, token, trunk_id) do
      {:ok, trunk_info}
    else
      error -> TwirpUtils.handle_twirp_response(error)
    end
  end

  def list_outbound_trunks(%__MODULE__{} = svc, opts \\ %{}) do
    with {:ok, client} <- ensure_client(svc),
         {:ok, token} <- admin_token(svc),
         {:ok, %{"items" => items}} <- Client.list_outbound_trunks(client, token, opts) do
      {:ok, items}
    else
      error -> TwirpUtils.handle_twirp_response(error)
    end
  end

  def delete_trunk(%__MODULE__{} = svc, trunk_id) do
    with {:ok, client} <- ensure_client(svc),
         {:ok, token} <- admin_token(svc),
         {:ok, trunk_info} <- Client.delete_trunk(client, token, trunk_id) do
      {:ok, trunk_info}
    else
      error -> TwirpUtils.handle_twirp_response(error)
    end
  end

  # --- dispatch rules ---
  def create_dispatch_rule(%__MODULE__{} = svc, rule \\ %{}) do
    with {:ok, client} <- ensure_client(svc),
         {:ok, token} <- admin_token(svc),
         {:ok, info} <- Client.create_dispatch_rule(client, token, rule) do
      {:ok, info}
    else
      error -> TwirpUtils.handle_twirp_response(error)
    end
  end

  def update_dispatch_rule(%__MODULE__{} = svc, rule_id, action) do
    with {:ok, client} <- ensure_client(svc),
         {:ok, token} <- admin_token(svc),
         {:ok, info} <- Client.update_dispatch_rule(client, token, rule_id, action) do
      {:ok, info}
    else
      error -> TwirpUtils.handle_twirp_response(error)
    end
  end

  def list_dispatch_rules(%__MODULE__{} = svc, opts \\ %{}) do
    with {:ok, client} <- ensure_client(svc),
         {:ok, token} <- admin_token(svc),
         {:ok, %{"items" => items}} <- Client.list_dispatch_rules(client, token, opts) do
      {:ok, items}
    else
      error -> TwirpUtils.handle_twirp_response(error)
    end
  end

  def delete_dispatch_rule(%__MODULE__{} = svc, rule_id) do
    with {:ok, client} <- ensure_client(svc),
         {:ok, token} <- admin_token(svc),
         {:ok, info} <- Client.delete_dispatch_rule(client, token, rule_id) do
      {:ok, info}
    else
      error -> TwirpUtils.handle_twirp_response(error)
    end
  end

  # --- participants ---
  def create_participant(%__MODULE__{} = svc, req) do
    with {:ok, client} <- ensure_client(svc),
         {:ok, token} <- call_token(svc),
         {:ok, info} <- Client.create_participant(client, token, req) do
      {:ok, info}
    else
      error -> TwirpUtils.handle_twirp_response(error)
    end
  end

  def transfer_participant(%__MODULE__{} = svc, req) do
    with {:ok, client} <- ensure_client(svc),
         {:ok, token} <- call_token(svc),
         {:ok, _} <- Client.transfer_participant(client, token, req) do
      :ok
    else
      error -> TwirpUtils.handle_twirp_response(error)
    end
  end
end

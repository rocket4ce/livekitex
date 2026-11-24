defmodule Livekitex do
  @moduledoc """
  Elixir server SDK for [LiveKit](https://livekit.io).

  ## Configuration

      # config/runtime.exs
      config :livekitex,
        url: System.fetch_env!("LIVEKIT_URL"),          # e.g. "wss://my-project.livekit.cloud"
        api_key: System.fetch_env!("LIVEKIT_API_KEY"),
        api_secret: System.fetch_env!("LIVEKIT_API_SECRET")

  ## Quick tour

      client = Livekitex.client()

      {:ok, room} = Livekitex.RoomService.create_room(client, "standup")

      {:ok, jwt} = Livekitex.room_join_token("alice", "standup")

      {:ok, _dispatch} =
        Livekitex.AgentDispatchService.create_dispatch(client, "standup", "notetaker")

  ## Services

    * `Livekitex.RoomService` - rooms, participants, data, RPC
    * `Livekitex.EgressService` - recording and streaming
    * `Livekitex.IngressService` - RTMP/WHIP/URL ingestion
    * `Livekitex.SIPService` - SIP trunks, dispatch rules, calls
    * `Livekitex.AgentDispatchService` - dispatching LiveKit Agents
    * `Livekitex.ConnectorService` - WhatsApp/Twilio (experimental, Cloud)
    * `Livekitex.PhoneNumberService` - phone numbers (experimental, Cloud)

  Tokens: `Livekitex.AccessToken`, `Livekitex.TokenVerifier`.
  Webhooks: `Livekitex.Webhook`, `Livekitex.Webhook.Plug`.
  Token endpoint for client SDKs: `Livekitex.TokenSource.Plug`.
  """

  alias Livekitex.{AccessToken, Client, Config, Webhook}

  @version Mix.Project.config()[:version]

  @doc """
  Builds a `Livekitex.Client` from options, falling back to application config.
  See `Livekitex.Client.new/1`.
  """
  @spec client(keyword()) :: Client.t()
  def client(opts \\ []), do: Client.new(opts)

  @doc false
  @deprecated "Use Livekitex.client/1"
  def room_service, do: client()

  @doc false
  @deprecated "Use Livekitex.client/1"
  def egress_service, do: client()

  @doc false
  @deprecated "Use Livekitex.client/1"
  def sip_service(opts \\ []), do: client(opts)

  @doc """
  Builds an access token using the configured credentials.

  `opts` are passed to `Livekitex.AccessToken.create/3` (`:name`, `:ttl`, `:metadata`,
  `:attributes`, `:kind`).
  """
  @spec access_token(String.t(), keyword()) :: AccessToken.t()
  def access_token(identity, opts \\ []) do
    config = Config.get()
    AccessToken.create(config.api_key, config.api_secret, Keyword.put(opts, :identity, identity))
  end

  @doc """
  Signs a token that lets `identity` join `room`.

  ## Options

    * `:can_publish`, `:can_subscribe`, `:can_publish_data`, `:can_publish_sources`,
      `:hidden` and any other `VideoGrant` field
    * `:room_config` - room configuration applied if this token creates the room,
      e.g. `[agents: [[agent_name: "notetaker"]]]`
    * `:name`, `:ttl`, `:metadata`, `:attributes`, `:kind`
  """
  @spec room_join_token(String.t(), String.t(), keyword()) :: {:ok, String.t()} | {:error, term()}
  def room_join_token(identity, room, opts \\ [])

  def room_join_token(_identity, room, _opts) when room in [nil, ""],
    do: {:error, :room_required}

  def room_join_token(identity, room, opts) do
    {token_opts, opts} = Keyword.split(opts, [:name, :ttl, :metadata, :attributes, :kind])
    {room_config, grant_opts} = Keyword.pop(opts, :room_config)

    identity
    |> access_token(token_opts)
    |> AccessToken.set_video_grant(Keyword.merge([room_join: true, room: room], grant_opts))
    |> then(&if(room_config, do: AccessToken.set_room_config(&1, room_config), else: &1))
    |> AccessToken.to_jwt()
    |> case do
      {:ok, jwt, _claims} -> {:ok, jwt}
      error -> error
    end
  end

  @doc """
  Signs an administrative token (room create/list/admin and recording).
  Prefer the service modules, which mint narrowly scoped tokens per call.
  """
  @spec admin_token(keyword()) :: {:ok, String.t()} | {:error, term()}
  def admin_token(opts \\ []) do
    config = Config.get()

    grant =
      Keyword.merge(
        [room_create: true, room_list: true, room_admin: true, room_record: true],
        Keyword.take(opts, [:room])
      )

    config.api_key
    |> AccessToken.create(config.api_secret, Keyword.take(opts, [:identity, :ttl]))
    |> AccessToken.set_video_grant(grant)
    |> AccessToken.to_jwt()
    |> case do
      {:ok, jwt, _claims} -> {:ok, jwt}
      error -> error
    end
  end

  @doc "Verifies and decodes a webhook. See `Livekitex.Webhook.receive_event/3`."
  defdelegate receive_webhook(body, auth_header, opts \\ []), to: Webhook, as: :receive_event

  @doc "Returns the library version."
  @spec version() :: String.t()
  def version, do: @version

  @doc """
  Returns the resolved configuration.

  The map contains the API secret and has no `Inspect` protection; see
  `Livekitex.Config.get/0`.
  """
  defdelegate config, to: Config, as: :get

  @doc "Sets a runtime configuration override."
  defdelegate configure(key, value), to: Config, as: :put
end

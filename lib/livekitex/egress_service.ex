defmodule Livekitex.EgressService do
  @behaviour Livekitex.EgressServiceBehaviour
  @moduledoc """
  Provides functionality to interact with the LiveKit EgressService API using Twirp.
  """

  alias Livekitex.AccessToken
  alias Livekitex.Grants
  alias Livekitex.TwirpUtils
  alias Livekitex.EgressServiceClient

  require Logger

  defstruct api_key: nil,
            api_secret: nil,
            host: "localhost",
            port: 7880,
            client: nil

  @type t :: %Livekitex.EgressService{
          api_key: String.t(),
          api_secret: String.t(),
          host: String.t(),
          port: integer(),
          client: Tesla.Client.t() | nil
        }

  def create(api_key, api_secret, options \\ []) do
    %__MODULE__{
      api_key: api_key,
      api_secret: api_secret,
      host: Keyword.get(options, :host, "localhost"),
      port: Keyword.get(options, :port, 7880)
    }
  end

  def start_room_composite_egress(%__MODULE__{} = egress_service, request) do
    with {:ok, client} <- ensure_client(egress_service),
         {:ok, token} <- create_token(egress_service) do
      case EgressServiceClient.start_room_composite_egress(client, request, token) do
        {:ok, egress_info} -> {:ok, egress_info}
        error -> TwirpUtils.handle_twirp_response(error)
      end
    end
  end

  def start_track_composite_egress(%__MODULE__{} = egress_service, request) do
    with {:ok, client} <- ensure_client(egress_service),
         {:ok, token} <- create_token(egress_service) do
      case EgressServiceClient.start_track_composite_egress(client, request, token) do
        {:ok, egress_info} -> {:ok, egress_info}
        error -> TwirpUtils.handle_twirp_response(error)
      end
    end
  end

  def start_track_egress(%__MODULE__{} = egress_service, request) do
    with {:ok, client} <- ensure_client(egress_service),
         {:ok, token} <- create_token(egress_service) do
      case EgressServiceClient.start_track_egress(client, request, token) do
        {:ok, egress_info} -> {:ok, egress_info}
        error -> TwirpUtils.handle_twirp_response(error)
      end
    end
  end

  def start_web_egress(%__MODULE__{} = egress_service, request) do
    with {:ok, client} <- ensure_client(egress_service),
         {:ok, token} <- create_token(egress_service) do
      case EgressServiceClient.start_web_egress(client, request, token) do
        {:ok, egress_info} -> {:ok, egress_info}
        error -> TwirpUtils.handle_twirp_response(error)
      end
    end
  end

  def start_participant_egress(%__MODULE__{} = egress_service, request) do
    with {:ok, client} <- ensure_client(egress_service),
         {:ok, token} <- create_token(egress_service) do
      case EgressServiceClient.start_participant_egress(client, request, token) do
        {:ok, egress_info} -> {:ok, egress_info}
        error -> TwirpUtils.handle_twirp_response(error)
      end
    end
  end

  def update_layout(%__MODULE__{} = egress_service, request) do
    with {:ok, client} <- ensure_client(egress_service),
         {:ok, token} <- create_token(egress_service) do
      case EgressServiceClient.update_layout(client, request, token) do
        {:ok, egress_info} -> {:ok, egress_info}
        error -> TwirpUtils.handle_twirp_response(error)
      end
    end
  end

  def update_stream(%__MODULE__{} = egress_service, request) do
    with {:ok, client} <- ensure_client(egress_service),
         {:ok, token} <- create_token(egress_service) do
      case EgressServiceClient.update_stream(client, request, token) do
        {:ok, egress_info} -> {:ok, egress_info}
        error -> TwirpUtils.handle_twirp_response(error)
      end
    end
  end

  def list_egress(%__MODULE__{} = egress_service, request) do
    with {:ok, client} <- ensure_client(egress_service),
         {:ok, token} <- create_token(egress_service) do
      case EgressServiceClient.list_egress(client, request, token) do
        {:ok, response} -> {:ok, response}
        error -> TwirpUtils.handle_twirp_response(error)
      end
    end
  end

  def stop_egress(%__MODULE__{} = egress_service, request) do
    with {:ok, client} <- ensure_client(egress_service),
         {:ok, token} <- create_token(egress_service) do
      case EgressServiceClient.stop_egress(client, request, token) do
        {:ok, egress_info} -> {:ok, egress_info}
        error -> TwirpUtils.handle_twirp_response(error)
      end
    end
  end

  defp ensure_client(%__MODULE__{client: nil} = egress_service) do
    base_url = "http://#{egress_service.host}:#{egress_service.port}"
    client = TwirpUtils.create_client(base_url)
    {:ok, client}
  end

  defp ensure_client(%__MODULE__{client: client}), do: {:ok, client}

  defp create_token(%__MODULE__{api_key: api_key, api_secret: api_secret}) do
    video_grant = %Grants.VideoGrant{room_admin: true}
    grants = %Grants.ClaimGrant{video: video_grant}

    api_key
    |> AccessToken.create(api_secret, grants: grants)
    |> AccessToken.set_video_grant(video_grant)
    |> AccessToken.to_jwt()
    |> case do
      {:ok, jwt, _claims} -> {:ok, jwt}
      error -> error
    end
  end
end

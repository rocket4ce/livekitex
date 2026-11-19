defmodule Livekitex.IngressService do
  @moduledoc """
  Media ingestion from RTMP, WHIP and URLs (`livekit.Ingress`).

  All calls use a token with the `ingressAdmin` grant.

      {:ok, ingress} =
        Livekitex.IngressService.create_ingress(client, :RTMP_INPUT,
          name: "obs",
          room_name: "live",
          participant_identity: "streamer"
        )

      ingress.url        # RTMP URL to stream to
      ingress.stream_key # stream key

  Input types: `:RTMP_INPUT`, `:WHIP_INPUT`, `:URL_INPUT` (the latter requires `url:`).
  """

  import Livekitex.Service

  alias Livekitex.Client

  alias Livekitex.Proto.Livekit.{
    CreateIngressRequest,
    DeleteIngressRequest,
    IngressInfo,
    ListIngressRequest,
    ListIngressResponse,
    UpdateIngressRequest
  }

  @service "Ingress"
  @grants [video: [ingress_admin: true]]

  @type result(t) :: {:ok, t} | {:error, Livekitex.Error.t()}

  @doc """
  Creates an ingress. Not retried by default (a retry could create a duplicate).
  """
  @spec create_ingress(Client.t(), atom() | CreateIngressRequest.t(), keyword()) ::
          result(IngressInfo.t())
  def create_ingress(client, input_type_or_request, opts \\ []) do
    {call_opts, fields} = split_opts(opts)

    request =
      case input_type_or_request do
        type when is_atom(type) or is_integer(type) -> Keyword.put(fields, :input_type, type)
        other -> merge_fields(other, fields)
      end

    rpc(
      client,
      @service,
      "CreateIngress",
      CreateIngressRequest,
      request,
      IngressInfo,
      @grants,
      no_retry(call_opts)
    )
  end

  @doc "Updates an ingress (name, room, participant, audio/video options, ...)."
  @spec update_ingress(Client.t(), String.t(), keyword()) :: result(IngressInfo.t())
  def update_ingress(client, ingress_id, opts) do
    {call_opts, fields} = split_opts(opts)
    fields = Keyword.put(fields, :ingress_id, ingress_id)

    rpc(
      client,
      @service,
      "UpdateIngress",
      UpdateIngressRequest,
      fields,
      IngressInfo,
      @grants,
      call_opts
    )
  end

  @doc """
  Lists ingresses, optionally filtered by `:room_name` or `:ingress_id`; pass
  `page_token: [token: next_page_token]` for the next page.

  Returns the full `ListIngressResponse` (`items` and `next_page_token`).
  """
  @spec list_ingress(Client.t(), keyword()) :: result(ListIngressResponse.t())
  def list_ingress(client, opts \\ []) do
    {call_opts, fields} = split_opts(opts)

    client
    |> rpc(
      @service,
      "ListIngress",
      ListIngressRequest,
      fields,
      ListIngressResponse,
      @grants,
      call_opts
    )
  end

  @doc "Deletes an ingress and returns its final state."
  @spec delete_ingress(Client.t(), String.t(), keyword()) :: result(IngressInfo.t())
  def delete_ingress(client, ingress_id, opts \\ []) do
    call_opts = call_opts!(opts)

    rpc(
      client,
      @service,
      "DeleteIngress",
      DeleteIngressRequest,
      [ingress_id: ingress_id],
      IngressInfo,
      @grants,
      call_opts
    )
  end
end

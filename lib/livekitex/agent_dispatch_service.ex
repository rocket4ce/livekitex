defmodule Livekitex.AgentDispatchService do
  @moduledoc """
  Explicit agent dispatch (`livekit.AgentDispatchService`).

  Agents built with LiveKit Agents (Python or Node.js) that register with an
  `agent_name` are only dispatched explicitly, either with this service or through
  `roomConfig.agents` in a participant token (see `Livekitex.AccessToken.set_room_config/2`).

      {:ok, dispatch} =
        Livekitex.AgentDispatchService.create_dispatch(client, "support-room", "support-agent",
          metadata: ~s({"customer_id": 42})
        )

  All calls use a token with `roomAdmin` for the target room.
  """

  import Livekitex.Service

  alias Livekitex.Client

  alias Livekitex.Proto.Livekit.{
    AgentDispatch,
    CreateAgentDispatchRequest,
    DeleteAgentDispatchRequest,
    ListAgentDispatchRequest,
    ListAgentDispatchResponse
  }

  @service "AgentDispatchService"

  @type result(t) :: {:ok, t} | {:error, Livekitex.Error.t()}

  @doc """
  Dispatches an agent to a room.

  ## Options

    * `:metadata` - string passed to the agent job
    * `:attributes` - map of attributes for the agent participant
    * `:deployment` - target deployment (LiveKit Cloud; defaults to production)
    * `:restart_policy` - `:JRP_ON_FAILURE` (default) or `:JRP_NEVER` (LiveKit Cloud)
    * `:thread_id` - agent thread id

  Not retried by default (a retry could dispatch the agent twice).
  """
  @spec create_dispatch(Client.t(), String.t(), String.t(), keyword()) ::
          result(AgentDispatch.t())
  def create_dispatch(client, room, agent_name, opts \\ []) do
    {call_opts, fields} = split_opts(opts)
    fields = Keyword.merge(fields, room: room, agent_name: agent_name)

    rpc(
      client,
      @service,
      "CreateDispatch",
      CreateAgentDispatchRequest,
      fields,
      AgentDispatch,
      grants(room),
      no_retry(call_opts)
    )
  end

  @doc "Deletes a dispatch from `room`. Returns the deleted dispatch."
  @spec delete_dispatch(Client.t(), String.t(), String.t(), keyword()) ::
          result(AgentDispatch.t())
  def delete_dispatch(client, room, dispatch_id, opts \\ []) do
    call_opts = call_opts!(opts)
    fields = [dispatch_id: dispatch_id, room: room]

    rpc(
      client,
      @service,
      "DeleteDispatch",
      DeleteAgentDispatchRequest,
      fields,
      AgentDispatch,
      grants(room),
      call_opts
    )
  end

  @doc "Lists the dispatches of a room."
  @spec list_dispatch(Client.t(), String.t(), keyword()) :: result([AgentDispatch.t()])
  def list_dispatch(client, room, opts \\ []) do
    {call_opts, fields} = split_opts(opts)
    fields = Keyword.put(fields, :room, room)

    client
    |> rpc(
      @service,
      "ListDispatch",
      ListAgentDispatchRequest,
      fields,
      ListAgentDispatchResponse,
      grants(room),
      call_opts
    )
    |> map_ok(& &1.agent_dispatches)
  end

  @doc "Gets a dispatch of `room` by id. Returns `{:ok, nil}` if it does not exist."
  @spec get_dispatch(Client.t(), String.t(), String.t(), keyword()) ::
          result(AgentDispatch.t() | nil)
  def get_dispatch(client, room, dispatch_id, opts \\ []) do
    client
    |> list_dispatch(room, Keyword.put(opts, :dispatch_id, dispatch_id))
    |> map_ok(&List.first/1)
  end

  defp grants(room), do: [video: [room_admin: true, room: room]]
end

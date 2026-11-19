defmodule Livekitex.Service do
  @moduledoc false
  # Shared helpers for the service modules.

  alias Livekitex.{Client, Twirp}

  @call_opts [:timeout, :retry, :request_id]

  @doc false
  # Splits call options (timeout/retry/request_id) from request fields.
  def split_opts(opts) when is_list(opts), do: Keyword.split(opts, @call_opts)

  @doc false
  # For functions whose request is fully positional: only call options are accepted,
  # so typos like `tiemout:` fail loudly instead of being ignored.
  def call_opts!(opts) when is_list(opts) do
    case Keyword.split(opts, @call_opts) do
      {call_opts, []} ->
        call_opts

      {_, unknown} ->
        raise ArgumentError,
              "unknown options #{inspect(Keyword.keys(unknown))}, expected #{inspect(@call_opts)}"
    end
  end

  @doc false
  # Extends the HTTP timeout to cover ringing when a call waits until answered.
  def dial_timeout(call_opts, request, default_ringing \\ 30) do
    if field(request, :wait_until_answered) do
      ringing =
        case field(request, :ringing_timeout) do
          seconds when is_integer(seconds) -> seconds
          %Google.Protobuf.Duration{seconds: seconds} -> seconds
          _ -> default_ringing
        end

      Keyword.put_new(call_opts, :timeout, (ringing + 10) * 1_000)
    else
      call_opts
    end
  end

  defp field(request, key) when is_list(request), do: request[key]
  defp field(request, key) when is_map(request), do: Map.get(request, key)

  @doc false
  def rpc(
        %Client{} = client,
        service,
        method,
        request_module,
        fields,
        response_module,
        grants,
        call_opts
      ) do
    request = Twirp.build(request_module, fields)
    Twirp.call(client, service, method, request, response_module, grants, call_opts)
  end

  def rpc(other, _service, _method, _req, _fields, _resp, _grants, _opts) do
    raise ArgumentError,
          "expected a %Livekitex.Client{} as the first argument, got: #{inspect(other)}"
  end

  @doc false
  # Disables retries unless the caller asked for them explicitly.
  def no_retry(call_opts), do: Keyword.put_new(call_opts, :retry, false)

  @doc false
  def map_ok({:ok, value}, fun), do: {:ok, fun.(value)}
  def map_ok({:error, _} = error, _fun), do: error

  @doc false
  def to_ok({:ok, _}), do: :ok
  def to_ok({:error, _} = error), do: error

  @doc false
  # Merges positional fields into a request given as a struct or keyword list.
  def merge_fields(%_{} = struct, fields), do: struct!(struct, fields)
  def merge_fields(opts, fields) when is_list(opts), do: Keyword.merge(opts, fields)
end

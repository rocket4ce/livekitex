defmodule Livekitex.Twirp do
  @moduledoc """
  Low-level Twirp transport used by every service module.

  Requests are sent as `POST {base_url}/twirp/livekit.{Service}/{Method}` with a
  protobuf-encoded body and a short-lived access token carrying exactly the grants
  the RPC needs.

  ## Retries

  Transport errors other than timeouts and HTTP 502/503/504 are retried. The default
  policy is 3 attempts with exponential backoff starting at 200 ms (plus jitter), and the
  same `x-livekit-request-id` header is sent on every attempt.

  A connection can fail after LiveKit already processed the request, so a retried
  delete may report `:not_found`. RPCs whose repetition has side effects (dialing SIP
  calls, starting egress, sending data, creating ingresses, trunks, rules or dispatches,
  moving or forwarding participants, purchasing phone numbers, ...) are never retried
  unless the caller passes `retry: true` explicitly.

  The policy is set per client (`Livekitex.Client.new(retry: false)`) or per call
  (`retry: [max_attempts: 5, base_delay: 100]`).

  ## Telemetry

  Each call is wrapped in `:telemetry.span/3` with the event prefix
  `[:livekitex, :request]`, so it emits:

    * `[:livekitex, :request, :start]` - metadata: `:service`, `:method`, `:request_id`, `:base_url`
    * `[:livekitex, :request, :stop]` - adds `:status` (HTTP status or `nil`), `:attempts`,
      and `:error` (`nil` or the `Livekitex.Error` code)
    * `[:livekitex, :request, :exception]` - if the call raises
  """

  alias Livekitex.{AccessToken, Client, Error}

  @version Mix.Project.config()[:version]
  @service_token_ttl 600
  @retry_statuses [502, 503, 504]
  @default_retry [max_attempts: 3, base_delay: 200]

  @type grants :: keyword()

  @doc """
  Performs a Twirp call.

    * `service` - the service name without package, e.g. `"RoomService"`
    * `method` - the RPC name, e.g. `"CreateRoom"`
    * `request` - a generated request struct
    * `response_module` - the generated module used to decode the response
    * `grants` - grants for the service token, e.g. `[video: [room_admin: true, room: "r"]]`

  ## Options

    * `:timeout` - connect and receive timeout in milliseconds (defaults to the client's)
    * `:retry` - `true`, `false` or `[max_attempts: n, base_delay: ms]`
    * `:request_id` - override the generated `x-livekit-request-id`
  """
  @spec call(Client.t(), String.t(), String.t(), struct(), module(), grants(), keyword()) ::
          {:ok, struct()} | {:error, Error.t()}
  def call(%Client{} = client, service, method, request, response_module, grants, opts \\ []) do
    request_id = opts[:request_id] || uuid4()

    metadata = %{
      service: service,
      method: method,
      request_id: request_id,
      base_url: client.base_url
    }

    :telemetry.span([:livekitex, :request], metadata, fn ->
      {result, status, attempts} =
        do_call(client, service, method, request, response_module, grants, request_id, opts)

      error_code =
        case result do
          {:error, %Error{code: code}} -> code
          _ -> nil
        end

      {result, Map.merge(metadata, %{status: status, attempts: attempts, error: error_code})}
    end)
  end

  @doc """
  Builds a request struct from a struct, keyword list or map.

  Nested messages may be given as keyword lists or maps, and a oneof member may be given
  by its field name:

      build(Livekitex.Proto.Livekit.StartEgressRequest,
        room_name: "r",
        template: [layout: "grid"],
        outputs: [[file: [filepath: "out.mp4"]]]
      )

  Unknown keys raise `KeyError`.
  """
  @spec build(module(), struct() | keyword() | map() | nil) :: struct()
  def build(module, %module{} = struct), do: struct
  def build(module, nil), do: struct(module)

  def build(module, fields) when is_list(fields) or is_map(fields) do
    props = module.__message_props__()
    by_name = Map.new(props.field_props, fn {_tag, fp} -> {fp.name_atom, fp} end)
    oneofs = Map.new(props.oneof, fn {name, index} -> {index, name} end)

    Enum.reduce(fields, struct(module), fn {key, value}, acc ->
      put_field(acc, module, by_name, oneofs, to_field_atom(key), value)
    end)
  end

  defp put_field(acc, module, by_name, oneofs, key, value) do
    case Map.fetch(by_name, key) do
      {:ok, %{oneof: index} = fp} when is_integer(index) ->
        Map.put(acc, Map.fetch!(oneofs, index), {key, convert(fp, value)})

      {:ok, fp} ->
        Map.put(acc, key, convert(fp, value))

      # oneof container given directly, e.g. `source: {:template, ...}`
      :error when key != :__struct__ and is_map_key(acc, key) ->
        Map.put(acc, key, value)

      :error ->
        raise KeyError, key: key, term: module
    end
  end

  defp to_field_atom(key) when is_atom(key), do: key

  defp to_field_atom(key) when is_binary(key) do
    String.to_existing_atom(key)
  rescue
    ArgumentError -> reraise KeyError, [key: key], __STACKTRACE__
  end

  defp convert(_fp, nil), do: nil

  defp convert(%{map?: true}, value) do
    Map.new(value, fn
      {key, val} when is_atom(key) -> {Atom.to_string(key), val}
      pair -> pair
    end)
  end

  # Durations may be given as whole seconds.
  defp convert(%{type: Google.Protobuf.Duration}, seconds) when is_integer(seconds),
    do: %Google.Protobuf.Duration{seconds: seconds}

  defp convert(%{repeated?: true, embedded?: true, type: type}, values) when is_list(values),
    do: Enum.map(values, &build(type, &1))

  defp convert(%{embedded?: true, type: type}, value)
       when is_list(value) or (is_map(value) and not is_struct(value)),
       do: build(type, value)

  defp convert(_fp, value), do: value

  ## Internals

  defp do_call(client, service, method, request, response_module, grants, request_id, opts) do
    ctx = %{service: service, method: method, request_id: request_id}

    case service_token(client, grants) do
      {:ok, token} ->
        req = build_req(client, service, method, request, token, request_id, opts)
        policy = retry_policy(Keyword.get(opts, :retry, client.retry))
        attempt(req, response_module, policy, 1, ctx)

      {:error, reason} ->
        error = %Error{
          code: :unauthenticated,
          msg: "could not sign service token",
          reason: reason,
          service: service,
          method: method,
          request_id: request_id
        }

        {{:error, error}, nil, 0}
    end
  end

  defp build_req(client, service, method, request, token, request_id, opts) do
    timeout = opts[:timeout] || client.timeout
    # Extra headers from `req_options` are added; they never replace the auth headers.
    {extra_headers, req_options} = Keyword.pop(client.req_options, :headers, [])

    [
      method: :post,
      base_url: client.base_url,
      url: "/twirp/livekit.#{service}/#{method}",
      body: Protobuf.encode(request),
      headers: [
        {"authorization", "Bearer " <> token},
        {"content-type", "application/protobuf"},
        {"user-agent", "livekitex/#{@version}"},
        {"x-livekit-request-id", request_id}
        | Enum.to_list(extra_headers)
      ],
      receive_timeout: timeout,
      connect_options: [timeout: timeout],
      retry: false,
      redirect: false,
      decode_body: false
    ]
    |> Keyword.merge(req_options)
    |> Req.new()
  end

  defp attempt(req, response_module, policy, n, ctx) do
    case Req.request(req) do
      {:ok, %Req.Response{status: status, body: body}} when status in 200..299 ->
        {decode_response(response_module, body, status, ctx), status, n}

      {:ok, %Req.Response{status: status}} when status in @retry_statuses and n < policy.max ->
        backoff(policy, n)
        attempt(req, response_module, policy, n + 1, ctx)

      {:ok, %Req.Response{} = response} ->
        {{:error, twirp_error(response, ctx)}, response.status, n}

      {:error, %Req.TransportError{reason: :timeout} = exception} ->
        {{:error, transport_error(:timeout, exception, ctx)}, nil, n}

      {:error, _exception} when n < policy.max ->
        backoff(policy, n)
        attempt(req, response_module, policy, n + 1, ctx)

      {:error, exception} ->
        {{:error, transport_error(:transport_error, exception, ctx)}, nil, n}
    end
  end

  defp decode_response(response_module, body, status, ctx) do
    {:ok, response_module.decode(IO.iodata_to_binary(body))}
  rescue
    exception ->
      {:error,
       %Error{
         code: :internal,
         msg: "could not decode #{inspect(response_module)} response",
         status: status,
         reason: exception,
         service: ctx.service,
         method: ctx.method,
         request_id: ctx.request_id
       }}
  end

  defp twirp_error(%Req.Response{status: status, body: body}, ctx) do
    base = %Error{
      status: status,
      service: ctx.service,
      method: ctx.method,
      request_id: ctx.request_id
    }

    case Jason.decode(IO.iodata_to_binary(body || "")) do
      {:ok, %{"code" => code} = json} ->
        %Error{
          base
          | code: Error.code_from_string(code),
            msg: redact(json["msg"]),
            meta: stringify_meta(json["meta"])
        }

      _ ->
        %Error{base | code: code_from_status(status), msg: body |> truncate() |> redact()}
    end
  end

  # LiveKit echoes rejected tokens in some error messages; keep them out of logs.
  defp redact(msg) when is_binary(msg),
    do: Regex.replace(~r/eyJ[\w-]+\.[\w-]+\.[\w-]+/, msg, "[REDACTED_JWT]")

  defp redact(msg), do: msg

  # Twirp spec: mapping for responses that are not Twirp errors.
  defp code_from_status(400), do: :internal
  defp code_from_status(401), do: :unauthenticated
  defp code_from_status(403), do: :permission_denied
  defp code_from_status(404), do: :bad_route
  defp code_from_status(status) when status in [429, 502, 503, 504], do: :unavailable
  defp code_from_status(_), do: :unknown

  defp stringify_meta(meta) when is_map(meta),
    do: Map.new(meta, fn {k, v} -> {to_string(k), meta_value(v)} end)

  defp stringify_meta(_), do: %{}

  defp meta_value(value) when is_binary(value), do: value
  defp meta_value(value) when is_number(value) or is_atom(value), do: to_string(value)
  defp meta_value(value), do: inspect(value)

  defp truncate(body) when is_binary(body) and byte_size(body) > 512,
    do: binary_part(body, 0, 512) <> "..."

  defp truncate(body) when is_binary(body) and body != "", do: body
  defp truncate(_), do: nil

  defp transport_error(code, exception, ctx) do
    %Error{
      code: code,
      msg: Exception.message(exception),
      reason: exception,
      service: ctx.service,
      method: ctx.method,
      request_id: ctx.request_id
    }
  end

  defp retry_policy(false), do: %{max: 1, base_delay: 0}
  defp retry_policy(nil), do: retry_policy(true)
  defp retry_policy(true), do: retry_policy(@default_retry)

  defp retry_policy(opts) when is_list(opts) do
    opts = Keyword.merge(@default_retry, opts)
    %{max: max(opts[:max_attempts], 1), base_delay: opts[:base_delay]}
  end

  defp backoff(%{base_delay: 0}, _n), do: :ok

  defp backoff(%{base_delay: base}, n) do
    delay = base * Integer.pow(2, n - 1)
    Process.sleep(delay + :rand.uniform(max(div(delay, 2), 1)))
  end

  defp service_token(client, grants) do
    client.api_key
    |> AccessToken.create(client.api_secret, ttl: @service_token_ttl)
    |> AccessToken.put_grants(grants)
    |> AccessToken.to_jwt()
    |> case do
      {:ok, jwt, _claims} -> {:ok, jwt}
      {:error, reason} -> {:error, reason}
    end
  end

  defp uuid4 do
    <<a::48, _::4, b::12, _::2, c::62>> = :crypto.strong_rand_bytes(16)

    <<a::48, 4::4, b::12, 2::2, c::62>>
    |> Base.encode16(case: :lower)
    |> then(fn <<p1::binary-8, p2::binary-4, p3::binary-4, p4::binary-4, p5::binary-12>> ->
      Enum.join([p1, p2, p3, p4, p5], "-")
    end)
  end
end

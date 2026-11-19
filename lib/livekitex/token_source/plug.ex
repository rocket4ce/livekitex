defmodule Livekitex.TokenSource.Plug do
  @moduledoc """
  A Plug implementing LiveKit's standard token endpoint, consumed by the client SDKs'
  `TokenSource.endpoint(...)` (JavaScript), `EndpointTokenSource` (Swift/Flutter),
  `TokenSource.fromEndpoint` (Kotlin) and friends.

  The client `POST`s a JSON body (`room_name`, `participant_identity`,
  `participant_name`, `participant_metadata`, `participant_attributes`, `room_config`)
  and receives `201` with `{"server_url": ..., "participant_token": ...}`.

      # Phoenix router, inside an authenticated pipeline
      forward "/api/livekit/token", Livekitex.TokenSource.Plug,
        authorize: &MyApp.LiveKitAuth.authorize/2

      defmodule MyApp.LiveKitAuth do
        # Everything in `request` comes from the client: decide here what is allowed.
        def authorize(conn, request) do
          user = conn.assigns.current_user

          {:ok,
           identity: "user-\#{user.id}",
           name: user.name,
           room: request.room_name || "lobby",
           video: [can_publish: true, can_subscribe: true]}
        end
      end

  ## The `:authorize` callback

  Receives the `Plug.Conn` and the decoded `Livekitex.Proto.Livekit.TokenSourceRequest`.
  It must return one of:

    * `{:ok, opts}` - build the token from `opts`:
      * `:identity` (required), `:name`, `:metadata`, `:attributes`, `:ttl`, `:kind`
      * `:room` - room to join (defaults to the request's `room_name`). If neither is
        given the plug answers `400`: a join token without a room would be valid for
        every room in the project.
      * `:video` - extra `VideoGrant` fields merged over `room_join: true, room: room`
      * `:room_config` - defaults to the request's `room_config` only when
        `allow_room_config: true` was given to the plug (dispatching agents from the
        client is otherwise ignored)
    * `{:ok, %Livekitex.AccessToken{}}` - use this token as is
    * `{:error, status}` - respond with that HTTP status (e.g. `401`, `403`)

  Responses: `201` on success, `400` for an invalid body or missing room, `413` for a
  body over 64 kB, `500` if the callback's options cannot produce a token (for example
  no `:identity`).

  ## Options

    * `:authorize` (required) - the callback above (2-arity function or `{module, function}`)
    * `:server_url` - public `wss://` URL returned to clients. Set it explicitly when your
      configured `:url` is an internal address (default: `Livekitex.Config` `:url`)
    * `:api_key`, `:api_secret` - signing credentials (default: `Livekitex.Config`)
    * `:allow_room_config` - accept the client's `room_config` (default `false`)
  """

  @behaviour Plug

  import Plug.Conn

  alias Livekitex.{AccessToken, Config}
  alias Livekitex.Proto.Livekit.TokenSourceRequest

  @max_body 64_000

  @impl Plug
  def init(opts) do
    authorize = Keyword.fetch!(opts, :authorize)

    unless is_function(authorize, 2) or match?({m, f} when is_atom(m) and is_atom(f), authorize) do
      raise ArgumentError, ":authorize must be a 2-arity function or a {module, function} tuple"
    end

    opts
  end

  @impl Plug
  def call(%Plug.Conn{method: "POST"} = conn, opts) do
    with {:ok, request, conn} <- read_request(conn),
         {:ok, token} <- authorize(conn, request, opts),
         {:ok, jwt, _claims} <- AccessToken.to_jwt(token) do
      body =
        Jason.encode!(%{
          "server_url" => opts[:server_url] || Config.get(:url),
          "participant_token" => jwt
        })

      conn
      |> put_resp_content_type("application/json")
      |> send_resp(201, body)
      |> halt()
    else
      {:error, status} when is_integer(status) -> send_error(conn, status)
      {:error, :bad_request} -> send_error(conn, 400)
      {:error, :room_required} -> send_error(conn, 400)
      {:error, :too_large} -> send_error(conn, 413)
      # e.g. the callback returned no :identity: a server-side bug, not a client error
      {:error, _} -> send_error(conn, 500)
    end
  end

  def call(conn, _opts) do
    conn |> put_resp_header("allow", "POST") |> send_resp(405, "") |> halt()
  end

  defp read_request(conn) do
    case conn.body_params do
      %Plug.Conn.Unfetched{} -> read_json_body(conn)
      params when is_map(params) and map_size(params) > 0 -> decode_params(params, conn)
      _ -> read_json_body(conn)
    end
  end

  defp read_json_body(conn) do
    case read_body(conn, length: @max_body) do
      {:ok, "", conn} -> {:ok, %TokenSourceRequest{}, conn}
      {:ok, body, conn} -> with({:ok, params} <- safe_json(body), do: decode_params(params, conn))
      {:more, _, _conn} -> {:error, :too_large}
      _ -> {:error, :bad_request}
    end
  end

  defp safe_json(body) do
    case Jason.decode(body) do
      {:ok, params} when is_map(params) -> {:ok, params}
      _ -> {:error, :bad_request}
    end
  end

  defp decode_params(params, conn) do
    case Protobuf.JSON.from_decoded(params, TokenSourceRequest, ignore_unknown_fields: true) do
      {:ok, request} -> {:ok, request, conn}
      {:error, _} -> {:error, :bad_request}
    end
  end

  defp authorize(conn, request, opts) do
    result =
      case opts[:authorize] do
        fun when is_function(fun, 2) -> fun.(conn, request)
        {module, function} -> apply(module, function, [conn, request])
      end

    case result do
      {:ok, %AccessToken{} = token} -> {:ok, token}
      {:ok, token_opts} when is_list(token_opts) -> build_token(request, token_opts, opts)
      {:error, status} when is_integer(status) -> {:error, status}
      _ -> {:error, 403}
    end
  end

  defp build_token(request, token_opts, opts) do
    api_key = opts[:api_key] || Config.get(:api_key)
    api_secret = opts[:api_secret] || Config.get(:api_secret)
    video = Keyword.merge([room_join: true], Keyword.get(token_opts, :video, []))
    room = Keyword.get(token_opts, :room, video[:room] || request.room_name)

    # A join grant without a room lets the holder join *any* room: refuse it.
    if room in [nil, ""] do
      {:error, :room_required}
    else
      room_config = room_config(token_opts, request, opts)

      token =
        api_key
        |> AccessToken.create(
          api_secret,
          Keyword.take(token_opts, [:identity, :name, :metadata, :attributes, :ttl, :kind])
        )
        |> AccessToken.set_video_grant(Keyword.put(video, :room, room))
        |> AccessToken.set_room_config(room_config)

      {:ok, token}
    end
  end

  defp room_config(token_opts, request, opts) do
    case Keyword.fetch(token_opts, :room_config) do
      {:ok, config} -> config
      :error -> if opts[:allow_room_config], do: request.room_config
    end
  end

  defp send_error(conn, status), do: conn |> send_resp(status, "") |> halt()
end

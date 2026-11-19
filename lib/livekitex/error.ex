defmodule Livekitex.Error do
  @moduledoc """
  Error returned by every LiveKit API call.

  Server-side failures carry the [Twirp error](https://twitchtv.github.io/twirp/docs/spec_v7.html#error-codes)
  `code`, `msg` and `meta` sent by LiveKit. Transport failures (connection refused,
  timeouts, TLS errors) use `code: :transport_error` or `code: :timeout` and keep the
  underlying exception in `reason`.

      case Livekitex.RoomService.create_room(client, "my-room") do
        {:ok, room} -> room
        {:error, %Livekitex.Error{code: :permission_denied, msg: msg}} -> ...
      end

  For SIP dialing errors use `sip_status/1` to read the SIP status code LiveKit
  attaches to the error metadata.
  """

  @twirp_codes ~w(canceled unknown invalid_argument malformed deadline_exceeded not_found
                  bad_route already_exists permission_denied unauthenticated resource_exhausted
                  failed_precondition aborted out_of_range unimplemented internal unavailable
                  dataloss)

  @type code ::
          :canceled
          | :unknown
          | :invalid_argument
          | :malformed
          | :deadline_exceeded
          | :not_found
          | :bad_route
          | :already_exists
          | :permission_denied
          | :unauthenticated
          | :resource_exhausted
          | :failed_precondition
          | :aborted
          | :out_of_range
          | :unimplemented
          | :internal
          | :unavailable
          | :dataloss
          | :transport_error
          | :timeout

  @type t :: %__MODULE__{
          code: code(),
          msg: String.t() | nil,
          meta: %{optional(String.t()) => String.t()},
          status: non_neg_integer() | nil,
          service: String.t() | nil,
          method: String.t() | nil,
          request_id: String.t() | nil,
          reason: term()
        }

  defexception code: :unknown,
               msg: nil,
               meta: %{},
               status: nil,
               service: nil,
               method: nil,
               request_id: nil,
               reason: nil

  @impl true
  def message(%__MODULE__{} = error) do
    where = if error.service, do: " (#{error.service}/#{error.method})", else: ""
    status = if error.status, do: " HTTP #{error.status}", else: ""
    detail = error.msg || (error.reason && inspect(error.reason)) || "no details"
    "LiveKit #{error.code}#{status}#{where}: #{detail}"
  end

  @doc """
  Converts a Twirp error code string into an atom without creating new atoms.

  Unknown codes map to `:unknown`.

      iex> Livekitex.Error.code_from_string("not_found")
      :not_found

      iex> Livekitex.Error.code_from_string("something_new")
      :unknown
  """
  @spec code_from_string(String.t() | nil) :: code()
  for code <- @twirp_codes do
    def code_from_string(unquote(code)), do: unquote(String.to_atom(code))
  end

  def code_from_string(_), do: :unknown

  @doc """
  Returns the SIP status attached to an error, if any.

  LiveKit includes `sip_status_code` and `sip_status` in the Twirp error metadata
  when an outbound call fails (for example, `486 Busy Here`).

      iex> error = %Livekitex.Error{meta: %{"sip_status_code" => "486", "sip_status" => "Busy Here"}}
      iex> Livekitex.Error.sip_status(error)
      {486, "Busy Here"}

      iex> Livekitex.Error.sip_status(%Livekitex.Error{})
      nil
  """
  @spec sip_status(t()) :: {integer(), String.t() | nil} | nil
  def sip_status(%__MODULE__{meta: meta}) when is_map(meta) do
    with code when is_binary(code) <- Map.get(meta, "sip_status_code"),
         {int, ""} <- Integer.parse(code) do
      {int, Map.get(meta, "sip_status")}
    else
      _ -> nil
    end
  end

  def sip_status(_), do: nil
end

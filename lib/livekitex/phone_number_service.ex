defmodule Livekitex.PhoneNumberService do
  @moduledoc """
  Phone numbers managed by LiveKit (`livekit.PhoneNumberService`).

  > #### Experimental · LiveKit Cloud only {: .warning}
  >
  > Purchasing numbers is billed to your LiveKit Cloud project. `purchase_phone_number/3`
  > and `release_phone_numbers/3` are never retried automatically.

  All calls use a token with the `sip.admin` grant.

      {:ok, %{items: available}} = Livekitex.PhoneNumberService.search_phone_numbers(client, "US", area_code: "415")
      {:ok, %{items: owned}} = Livekitex.PhoneNumberService.list_phone_numbers(client)
  """

  import Livekitex.Service

  alias Livekitex.Client

  alias Livekitex.Proto.Livekit.{
    GetPhoneNumberRequest,
    GetPhoneNumberResponse,
    ListPhoneNumbersRequest,
    ListPhoneNumbersResponse,
    PhoneNumber,
    PurchasePhoneNumberRequest,
    PurchasePhoneNumberResponse,
    ReleasePhoneNumbersRequest,
    ReleasePhoneNumbersResponse,
    SearchPhoneNumbersRequest,
    SearchPhoneNumbersResponse,
    UpdatePhoneNumberRequest,
    UpdatePhoneNumberResponse
  }

  @service "PhoneNumberService"
  @grants [sip: [admin: true]]

  @type result(t) :: {:ok, t} | {:error, Livekitex.Error.t()}

  @doc """
  Searches numbers available for purchase. Options: `:area_code`, `:limit`, `:page_token`.
  Returns the full response (`items`, `next_page_token`).
  """
  @spec search_phone_numbers(Client.t(), String.t(), keyword()) ::
          result(SearchPhoneNumbersResponse.t())
  def search_phone_numbers(client, country_code, opts \\ []) do
    {call_opts, fields} = split_opts(opts)
    fields = Keyword.put(fields, :country_code, country_code)

    rpc(
      client,
      @service,
      "SearchPhoneNumbers",
      SearchPhoneNumbersRequest,
      fields,
      SearchPhoneNumbersResponse,
      @grants,
      call_opts
    )
  end

  @doc """
  Purchases phone numbers (E.164). Pass `sip_dispatch_rule_id:` to attach them to a
  dispatch rule. **Billed to your project**; never retried automatically.
  """
  @spec purchase_phone_number(Client.t(), [String.t()], keyword()) ::
          result(PurchasePhoneNumberResponse.t())
  def purchase_phone_number(client, phone_numbers, opts \\ []) do
    {call_opts, fields} = split_opts(opts)
    fields = Keyword.put(fields, :phone_numbers, List.wrap(phone_numbers))

    rpc(
      client,
      @service,
      "PurchasePhoneNumber",
      PurchasePhoneNumberRequest,
      fields,
      PurchasePhoneNumberResponse,
      @grants,
      no_retry(call_opts)
    )
  end

  @doc """
  Lists the project's numbers. Options: `:limit`, `:statuses`, `:page_token`,
  `:sip_dispatch_rule_id`. Returns the full response (`items`, `next_page_token`,
  `total_count`, `offline_count`).
  """
  @spec list_phone_numbers(Client.t(), keyword()) :: result(ListPhoneNumbersResponse.t())
  def list_phone_numbers(client, opts \\ []) do
    {call_opts, fields} = split_opts(opts)

    rpc(
      client,
      @service,
      "ListPhoneNumbers",
      ListPhoneNumbersRequest,
      fields,
      ListPhoneNumbersResponse,
      @grants,
      call_opts
    )
  end

  @doc "Gets a number by `id:` or `phone_number:`."
  @spec get_phone_number(Client.t(), keyword()) :: result(PhoneNumber.t())
  def get_phone_number(client, opts) do
    {call_opts, fields} = split_opts(opts)

    client
    |> rpc(
      @service,
      "GetPhoneNumber",
      GetPhoneNumberRequest,
      fields,
      GetPhoneNumberResponse,
      @grants,
      call_opts
    )
    |> map_ok(& &1.phone_number)
  end

  @doc "Updates a number (by `id:` or `phone_number:`): `:name`, `:sip_dispatch_rule_id`."
  @spec update_phone_number(Client.t(), keyword()) :: result(PhoneNumber.t())
  def update_phone_number(client, opts) do
    {call_opts, fields} = split_opts(opts)

    client
    |> rpc(
      @service,
      "UpdatePhoneNumber",
      UpdatePhoneNumberRequest,
      fields,
      UpdatePhoneNumberResponse,
      @grants,
      call_opts
    )
    |> map_ok(& &1.phone_number)
  end

  @doc """
  Releases numbers by `ids:` and/or `phone_numbers:`. Never retried automatically.
  """
  @spec release_phone_numbers(Client.t(), keyword()) :: :ok | {:error, Livekitex.Error.t()}
  def release_phone_numbers(client, opts) do
    {call_opts, fields} = split_opts(opts)

    client
    |> rpc(
      @service,
      "ReleasePhoneNumbers",
      ReleasePhoneNumbersRequest,
      fields,
      ReleasePhoneNumbersResponse,
      @grants,
      no_retry(call_opts)
    )
    |> to_ok()
  end
end

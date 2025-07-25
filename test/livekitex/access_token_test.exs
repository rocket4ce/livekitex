defmodule Livekitex.AccessTokenTest do
  use ExUnit.Case, async: true

  alias Livekitex.AccessToken

  test "generates a valid JWT token" do
    token = AccessToken.create("devkey", "secret", identity: "user", name: "User Name")
    {:ok, jwt, _claims} = AccessToken.to_jwt(token)

    assert is_binary(jwt)
  end
end

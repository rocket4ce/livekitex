defmodule Livekitex.TokenVerifierTest do
  use ExUnit.Case, async: true

  alias Livekitex.{AccessToken, TokenVerifier}

  doctest Livekitex.TokenVerifier

  @verifier TokenVerifier.new("devkey", "secret")

  defp sign(claims, secret \\ "secret") do
    {:ok, jwt, _} = Joken.encode_and_sign(claims, Joken.Signer.create("HS256", secret))
    jwt
  end

  defp now, do: System.os_time(:second)

  test "verifies a token and returns its grants" do
    jwt =
      AccessToken.create("devkey", "secret", identity: "alice")
      |> AccessToken.set_video_grant(room_join: true, room: "r")
      |> AccessToken.set_sip_grant(call: true)
      |> AccessToken.to_jwt!()

    assert {:ok, grant} = TokenVerifier.verify(@verifier, jwt)
    assert grant.identity == "alice"
    assert grant.video.room_join
    assert grant.sip.call
  end

  test "rejects bad signature, issuer, expiry and garbage" do
    base = %{"iss" => "devkey", "exp" => now() + 60, "nbf" => now()}

    assert {:error, :invalid_signature} = TokenVerifier.verify(@verifier, sign(base, "other"))

    assert {:error, :invalid_issuer} =
             TokenVerifier.verify(@verifier, sign(%{base | "iss" => "x"}))

    assert {:error, :token_expired} =
             TokenVerifier.verify(@verifier, sign(%{base | "exp" => now() - 120}))

    assert {:error, :token_not_yet_valid} =
             TokenVerifier.verify(@verifier, sign(%{base | "nbf" => now() + 600}))

    assert {:error, :missing_expiration} =
             TokenVerifier.verify(@verifier, sign(Map.delete(base, "exp")))

    assert {:error, :invalid_token} = TokenVerifier.verify(@verifier, "not-a-jwt")
  end

  test "leeway tolerates clock skew" do
    jwt = sign(%{"iss" => "devkey", "exp" => now() - 30})
    assert {:ok, _} = TokenVerifier.verify(@verifier, jwt)

    assert {:error, :token_expired} =
             TokenVerifier.verify(TokenVerifier.new("devkey", "secret", leeway: 0), jwt)
  end

  test "verify_permissions checks video and sip grants" do
    jwt =
      AccessToken.create("devkey", "secret", identity: "a")
      |> AccessToken.set_video_grant(room_join: true, room: "r")
      |> AccessToken.set_sip_grant(call: true)
      |> AccessToken.to_jwt!()

    assert {:ok, _} = TokenVerifier.verify_permissions(@verifier, jwt, room_join: true)

    assert {:ok, _} =
             TokenVerifier.verify_permissions(@verifier, jwt,
               video: [room: "r"],
               sip: [call: true]
             )

    assert {:error, {:missing_permissions, [sip: {:admin, true}]}} =
             TokenVerifier.verify_permissions(@verifier, jwt, sip: [admin: true])
  end

  test "decode_claims does not verify" do
    jwt = sign(%{"sub" => "x", "iss" => "other"}, "other")
    assert {:ok, %{identity: "x"}} = TokenVerifier.decode_claims(jwt)
    assert {:error, :invalid_token} = TokenVerifier.decode_claims("garbage")
  end
end

defmodule Livekitex.TokenVerifierTest do
  use ExUnit.Case, async: true

  alias Livekitex.{AccessToken, TokenVerifier}
  alias Livekitex.Grants.{VideoGrant, SipGrant}

  @api_key "devkey"
  @api_secret "secret"

  describe "new/2" do
    test "creates a new TokenVerifier" do
      verifier = TokenVerifier.new(@api_key, @api_secret)

      assert %TokenVerifier{} = verifier
      assert verifier.api_key == @api_key
      assert verifier.api_secret == @api_secret
    end
  end

  describe "verify/2" do
    test "successfully verifies a valid token" do
      # Create a token
      token = AccessToken.create(@api_key, @api_secret, identity: "user123", name: "Test User")
      video_grant = VideoGrant.new(room_join: true, can_publish: true)
      token = AccessToken.set_video_grant(token, video_grant)

      {:ok, jwt, _claims} = AccessToken.to_jwt(token)

      # Verify the token
      verifier = TokenVerifier.new(@api_key, @api_secret)
      {:ok, claim_grant} = TokenVerifier.verify(verifier, jwt)

      assert claim_grant.identity == "user123"
      assert claim_grant.name == "Test User"
      assert claim_grant.video.room_join == true
      assert claim_grant.video.can_publish == true
    end

    test "fails to verify token with wrong secret" do
      # Create a token
      token = AccessToken.create(@api_key, @api_secret, identity: "user123")
      video_grant = VideoGrant.new(room_join: true)
      token = AccessToken.set_video_grant(token, video_grant)

      {:ok, jwt, _claims} = AccessToken.to_jwt(token)

      # Try to verify with wrong secret
      verifier = TokenVerifier.new(@api_key, "wrong_secret")
      {:error, _reason} = TokenVerifier.verify(verifier, jwt)
    end

    test "fails to verify token with wrong API key" do
      # Create a token
      token = AccessToken.create(@api_key, @api_secret, identity: "user123")
      video_grant = VideoGrant.new(room_join: true)
      token = AccessToken.set_video_grant(token, video_grant)

      {:ok, jwt, _claims} = AccessToken.to_jwt(token)

      # Try to verify with wrong API key
      verifier = TokenVerifier.new("wrong_key", @api_secret)
      {:error, reason} = TokenVerifier.verify(verifier, jwt)

      assert reason =~ "Invalid issuer"
    end

    test "fails to verify malformed token" do
      verifier = TokenVerifier.new(@api_key, @api_secret)
      {:error, _reason} = TokenVerifier.verify(verifier, "invalid.jwt.token")
    end

    test "verifies token with SIP grants" do
      # Create a token with SIP grant
      token = AccessToken.create(@api_key, @api_secret, identity: "user123")
      sip_grant = SipGrant.new(admin: true, call: true)
      token = AccessToken.set_sip_grant(token, sip_grant)

      {:ok, jwt, _claims} = AccessToken.to_jwt(token)

      # Verify the token
      verifier = TokenVerifier.new(@api_key, @api_secret)
      {:ok, claim_grant} = TokenVerifier.verify(verifier, jwt)

      assert claim_grant.identity == "user123"
      assert claim_grant.sip.admin == true
      assert claim_grant.sip.call == true
    end

    test "verifies token with both video and SIP grants" do
      # Create a token with both grants
      token = AccessToken.create(@api_key, @api_secret, identity: "user123")
      video_grant = VideoGrant.new(room_join: true, can_publish: false)
      sip_grant = SipGrant.new(admin: true)
      token = AccessToken.set_video_grant(token, video_grant)
      token = AccessToken.set_sip_grant(token, sip_grant)

      {:ok, jwt, _claims} = AccessToken.to_jwt(token)

      # Verify the token
      verifier = TokenVerifier.new(@api_key, @api_secret)
      {:ok, claim_grant} = TokenVerifier.verify(verifier, jwt)

      assert claim_grant.identity == "user123"
      assert claim_grant.video.room_join == true
      assert claim_grant.video.can_publish == false
      assert claim_grant.sip.admin == true
    end
  end

  describe "verify!/2" do
    test "returns claims on successful verification" do
      # Create a token
      token = AccessToken.create(@api_key, @api_secret, identity: "user123")
      video_grant = VideoGrant.new(room_join: true)
      token = AccessToken.set_video_grant(token, video_grant)

      {:ok, jwt, _claims} = AccessToken.to_jwt(token)

      # Verify the token
      verifier = TokenVerifier.new(@api_key, @api_secret)
      claim_grant = TokenVerifier.verify!(verifier, jwt)

      assert claim_grant.identity == "user123"
      assert claim_grant.video.room_join == true
    end

    test "raises on verification failure" do
      verifier = TokenVerifier.new(@api_key, @api_secret)

      assert_raise RuntimeError, ~r/Token verification failed/, fn ->
        TokenVerifier.verify!(verifier, "invalid.jwt.token")
      end
    end
  end

  describe "decode_claims/1" do
    test "decodes token claims without verification" do
      # Create a token
      token = AccessToken.create(@api_key, @api_secret, identity: "user123", name: "Test User")
      video_grant = VideoGrant.new(room_join: true, can_publish: true)
      token = AccessToken.set_video_grant(token, video_grant)

      {:ok, jwt, _claims} = AccessToken.to_jwt(token)

      # Decode claims without verification
      {:ok, claim_grant} = TokenVerifier.decode_claims(jwt)

      assert claim_grant.identity == "user123"
      assert claim_grant.name == "Test User"
      assert claim_grant.video.room_join == true
      assert claim_grant.video.can_publish == true
    end

    test "fails to decode malformed token" do
      {:error, _reason} = TokenVerifier.decode_claims("invalid.jwt.token")
    end
  end

  describe "verify_permissions/3" do
    test "successfully verifies token with required permissions" do
      # Create a token with specific permissions
      token = AccessToken.create(@api_key, @api_secret, identity: "user123")
      video_grant = VideoGrant.new(room_join: true, can_publish: true, room_admin: false)
      token = AccessToken.set_video_grant(token, video_grant)

      {:ok, jwt, _claims} = AccessToken.to_jwt(token)

      # Verify with required permissions
      verifier = TokenVerifier.new(@api_key, @api_secret)

      {:ok, claim_grant} =
        TokenVerifier.verify_permissions(verifier, jwt, room_join: true, can_publish: true)

      assert claim_grant.identity == "user123"
      assert claim_grant.video.room_join == true
      assert claim_grant.video.can_publish == true
    end

    test "fails when token lacks required permissions" do
      # Create a token with limited permissions
      token = AccessToken.create(@api_key, @api_secret, identity: "user123")
      video_grant = VideoGrant.new(room_join: true, can_publish: false)
      token = AccessToken.set_video_grant(token, video_grant)

      {:ok, jwt, _claims} = AccessToken.to_jwt(token)

      # Try to verify with permissions the token doesn't have
      verifier = TokenVerifier.new(@api_key, @api_secret)

      {:error, reason} =
        TokenVerifier.verify_permissions(verifier, jwt, room_join: true, can_publish: true)

      assert reason =~ "Missing required permissions"
    end

    test "fails when token has no video grant" do
      # Create a token with only SIP grant
      token = AccessToken.create(@api_key, @api_secret, identity: "user123")
      sip_grant = SipGrant.new(admin: true)
      token = AccessToken.set_sip_grant(token, sip_grant)

      {:ok, jwt, _claims} = AccessToken.to_jwt(token)

      # Try to verify video permissions
      verifier = TokenVerifier.new(@api_key, @api_secret)
      {:error, reason} = TokenVerifier.verify_permissions(verifier, jwt, room_join: true)

      assert reason =~ "No video grant found in token"
    end

    test "handles nil permissions correctly" do
      # Create a token where some permissions are nil (not granted)
      token = AccessToken.create(@api_key, @api_secret, identity: "user123")
      video_grant = VideoGrant.new(room_join: true, can_publish: nil)
      token = AccessToken.set_video_grant(token, video_grant)

      {:ok, jwt, _claims} = AccessToken.to_jwt(token)

      # Try to verify a permission that is nil
      verifier = TokenVerifier.new(@api_key, @api_secret)
      {:error, reason} = TokenVerifier.verify_permissions(verifier, jwt, can_publish: true)

      assert reason =~ "Missing required permissions"
    end

    test "handles false permissions correctly" do
      # Create a token where some permissions are explicitly false
      token = AccessToken.create(@api_key, @api_secret, identity: "user123")
      video_grant = VideoGrant.new(room_join: true, can_publish: false)
      token = AccessToken.set_video_grant(token, video_grant)

      {:ok, jwt, _claims} = AccessToken.to_jwt(token)

      # Try to verify a permission that is false
      verifier = TokenVerifier.new(@api_key, @api_secret)
      {:error, reason} = TokenVerifier.verify_permissions(verifier, jwt, can_publish: true)

      assert reason =~ "Missing required permissions"
    end
  end
end

defmodule LivekitexTest do
  use ExUnit.Case
  doctest Livekitex

  test "returns version" do
    version = Livekitex.version()
    assert is_binary(version)
  end

  test "gets configuration" do
    # Set some test configuration first
    Application.put_env(:livekitex, :api_key, "test_key")
    Application.put_env(:livekitex, :api_secret, "test_secret")
    Application.put_env(:livekitex, :host, "localhost:7880")

    config = Livekitex.config()
    assert is_map(config)
    assert Map.has_key?(config, :host)
    assert Map.has_key?(config, :api_key)

    # Clean up
    Application.delete_env(:livekitex, :api_key)
    Application.delete_env(:livekitex, :api_secret)
    Application.delete_env(:livekitex, :host)
  end
end

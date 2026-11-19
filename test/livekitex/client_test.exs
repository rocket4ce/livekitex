defmodule Livekitex.ClientTest do
  use ExUnit.Case, async: false

  alias Livekitex.{Client, Config}

  doctest Livekitex.Client

  setup do
    on_exit(&Config.reset/0)
  end

  describe "normalize_url/1" do
    test "rewrites websocket schemes and strips paths" do
      assert Client.normalize_url("wss://demo.livekit.cloud") == "https://demo.livekit.cloud"
      assert Client.normalize_url("ws://10.0.0.1:7880/") == "http://10.0.0.1:7880"
      assert Client.normalize_url("https://lk.example.com:443/") == "https://lk.example.com"
      assert Client.normalize_url(" localhost:7880 ") == "http://localhost:7880"
    end

    test "rejects unsupported schemes" do
      assert_raise ArgumentError, fn -> Client.normalize_url("ftp://example.com") end
      assert_raise ArgumentError, fn -> Client.normalize_url(nil) end
    end
  end

  describe "new/1" do
    test "uses explicit options" do
      client = Client.new(url: "wss://x.livekit.cloud", api_key: "k", api_secret: "s", timeout: 5)

      assert %Client{
               base_url: "https://x.livekit.cloud",
               api_key: "k",
               api_secret: "s",
               timeout: 5
             } =
               client
    end

    test "falls back to configuration" do
      Config.put(:url, "wss://configured.livekit.cloud")
      client = Client.new()
      assert client.base_url == "https://configured.livekit.cloud"
      assert client.api_key == "devkey"
    end

    test "supports legacy host/port/use_tls options" do
      client = Client.new(host: "lk.example.com", port: 7443, use_tls: true)
      assert client.base_url == "https://lk.example.com:7443"

      client = Client.new(host: "localhost:7880", port: 7880)
      assert client.base_url == "http://localhost:7880"
    end

    test "requires credentials" do
      Config.put(:api_key, "")
      assert_raise ArgumentError, ~r/api_key and api_secret/, fn -> Client.new() end
    end
  end

  describe "Config" do
    test "maps legacy host config to url" do
      Config.put(:url, nil)
      Config.put(:host, "lk.internal")
      Config.put(:port, 7880)
      assert Config.get(:url) == "http://lk.internal:7880"
    end

    test "validate/0" do
      assert Config.validate() == :ok
      Config.put(:api_secret, "")
      assert {:error, _} = Config.validate()
    end
  end
end

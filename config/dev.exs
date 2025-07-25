import Config

config :livekitex,
  api_key: "devkey",
  api_secret: "secret",
  host: "localhost",
  port: 7880

# Tesla HTTP client configuration
config :tesla, Tesla.Adapter.Finch, name: Livekitex.Finch

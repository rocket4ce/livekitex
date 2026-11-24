defmodule Livekitex.MixProject do
  use Mix.Project

  @version "0.2.1"
  @source_url "https://github.com/rocket4ce/livekitex"

  def project do
    [
      app: :livekitex,
      version: @version,
      elixir: "~> 1.16",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: description(),
      package: package(),
      docs: docs(),
      source_url: @source_url,
      dialyzer: [plt_add_apps: [:mix]]
    ]
  end

  def application do
    [extra_applications: [:logger, :crypto]]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp description do
    """
    Elixir server SDK for LiveKit: access tokens, webhooks, and the full Twirp
    server API (rooms, egress, ingress, SIP, agent dispatch, connectors, phone numbers).
    """
  end

  defp package do
    [
      files: ~w(lib priv/protos .formatter.exs mix.exs README.md CHANGELOG.md LICENSE),
      licenses: ["Apache-2.0"],
      links: %{"GitHub" => @source_url, "Changelog" => "#{@source_url}/blob/main/CHANGELOG.md"},
      maintainers: ["Rocket4ce"]
    ]
  end

  defp docs do
    [
      main: "readme",
      source_ref: "v#{@version}",
      extras: ["README.md", "CHANGELOG.md"],
      groups_for_modules: [
        Client: [Livekitex, Livekitex.Client, Livekitex.Config, Livekitex.Error],
        Services: [
          Livekitex.RoomService,
          Livekitex.EgressService,
          Livekitex.IngressService,
          Livekitex.SIPService,
          Livekitex.AgentDispatchService,
          Livekitex.ConnectorService,
          Livekitex.PhoneNumberService
        ],
        Auth: [
          Livekitex.AccessToken,
          Livekitex.TokenVerifier,
          ~r/^Livekitex\.Grants/
        ],
        Plugs: [~r/^Livekitex\.Webhook/, ~r/^Livekitex\.TokenSource/],
        Internals: [Livekitex.Twirp],
        "Protocol (generated)": [~r/^Livekitex\.Proto\./]
      ],
      nest_modules_by_prefix: [Livekitex.Proto.Livekit]
    ]
  end

  defp deps do
    [
      {:protobuf, "~> 0.17"},
      {:req, "~> 0.7"},
      {:joken, "~> 2.6"},
      {:jason, "~> 1.4"},
      {:plug, "~> 1.14"},
      {:telemetry, "~> 1.2"},
      {:ex_doc, "~> 0.34", only: :dev, runtime: false},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false}
    ]
  end
end

defmodule Livekitex.MixProject do
  use Mix.Project

  def project do
    [
      app: :livekitex,
      version: "0.1.34",
      elixir: "~> 1.18",
      deps: deps(),
      description: description(),
      package: package()
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {Livekitex.Application, []}
    ]
  end

  defp description do
    """
    An Elixir client for LiveKit, providing tools for interacting with LiveKit servers,
    including access token generation, room management, and webhook verification.
    """
  end

  defp package do
    [
      files: ~w(lib .formatter.exs mix.exs README.md),
      licenses: ["Apache-2.0"],
      links: %{"GitHub" => "https://github.com/rocket4ce/livekitex"},
      maintainers: ["Rocket4ce"]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:protobuf, "~> 0.14.1", runtime: false},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:joken, "~> 2.6"},
      {:jason, "~> 1.4"},
      {:tesla, "~> 1.4"},
      {:finch, "~> 0.16"},
      {:plug, "~> 1.14"},
      {:telemetry, "~> 1.2"},
      {:ex_doc, "~> 0.32", only: :dev, runtime: false},
      {:mox, "~> 1.0", only: :test}
    ]
  end
end

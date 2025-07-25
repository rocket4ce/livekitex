defmodule Livekitex.MixProject do
  use Mix.Project

  def project do
    [
      app: :livekitex,
      version: "0.1.0",
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:protobuf, "~> 0.14.1"},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:joken, "~> 2.6"},
      {:jason, "~> 1.4"},
      {:grpc, "~> 0.7.0"},
      {:tesla, "~> 1.4"}
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
    ]
  end
end

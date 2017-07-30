defmodule Grafibot.Mixfile do
  use Mix.Project

  def project do
    [
      app: :grafibot,
      version: "0.1.0",
      elixir: "~> 1.3",
      start_permanent: Mix.env == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Grafibot.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:websockex, "~> 0.4.0"},
      {:poison, "~> 3.1"},
      {:httpoison, "~> 0.12.0"},
      {:dialyxir, "~> 0.5", only: [:dev], runtime: false},
      {:websockex, "~> 0.4.0"}
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"},
    ]
  end
end

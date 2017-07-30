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

  def application do
    [
      applications: [:poison, :httpoison, :websockex], # for elixir 1.3 compatibility
      extra_applications: [:logger],
      mod: {Grafibot.Application, []}
    ]
  end

  defp deps do
    [
      {:poison, "~> 3.1"},
      {:httpoison, "~> 0.12.0"},
      {:dialyxir, "~> 0.5", only: [:dev], runtime: false},
      {:websockex, "~> 0.4.0"}
    ]
  end
end

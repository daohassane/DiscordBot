defmodule Grafibot.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false
    table = :ets.new(:monbot, [:set, :public])
    children = [
      worker(Discord.Bot, [
        Application.get_env(:grafibot, :api_key),
        table,
        [debug: [:trace]]
      ])
    ]
    opts = [strategy: :one_for_one, name: Grafibot.Supervisor]
    Supervisor.start_link(children, opts)
  end
end

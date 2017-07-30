defmodule GrafibotTest do
  use ExUnit.Case
  doctest Grafibot

  test "greets the world" do
    assert Grafibot.hello() == :world
  end
end

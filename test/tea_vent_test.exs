defmodule TeaVentTest do
  use ExUnit.Case
  doctest TeaVent

  test "greets the world" do
    assert TeaVent.hello() == :world
  end
end

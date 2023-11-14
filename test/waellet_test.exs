defmodule WaelletTest do
  use ExUnit.Case
  doctest Waellet

  test "greets the world" do
    assert Waellet.hello() == :world
  end
end

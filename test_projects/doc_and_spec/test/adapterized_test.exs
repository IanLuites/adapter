defmodule AdapterizedTest do
  use ExUnit.Case
  doctest Adapterized

  test "greets the world" do
    assert Adapterized.hello() == :world
  end
end

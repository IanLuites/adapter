defmodule Adapterized.Application do
  @moduledoc false
  use Application
  require ExUnit.Assertions
  import ExUnit.Assertions, only: [assert: 1]

  def start(_type, _args) do
    assert Color.rgb() == {0, 0, 255}
    assert Color.red() == 0
    assert Color.configure(Red) == :ok
    assert Color.rgb() == {255, 0, 0}
    assert Color.red() == 255

    assert Storage.type() == :persistent
    assert Storage.persistent?() == true
    assert Storage.configure(Redis) == :ok
    assert Storage.type() == :cache
    assert Storage.persistent?() == false

    IO.puts("All tests passed.")
    System.halt(0)
  rescue
    e ->
      IO.puts(Exception.message(e))
      System.halt(1)
  end
end

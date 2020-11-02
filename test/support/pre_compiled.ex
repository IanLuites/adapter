defmodule PreCompiled do
  @moduledoc ~S"""
  Compilation of code is different when done at compile time [ex]
  vs compilation at runtime [exs | iex].

  Different code paths in `mode: :compile` take care of these situations.
  This however means that to test all code paths
  we also need to pre-compile an adapter module,
  since all tests run in at runtime. [exs]
  """
  use Adapter, mode: :compile, default: Adapter.CompileTest.Blue

  behavior do
    @doc ~S"A color's RGB value."
    @callback rgb :: {0..255, 0..255, 0..255}
  end

  def red, do: elem(rgb(), 0)
end

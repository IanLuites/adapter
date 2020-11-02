defmodule BenchCompiled do
  use Adapter, default: BenchCompiled.A, mode: :compile, log: false

  behavior do
    @doc ~S"Some docs"
    @callback some_function :: boolean
  end
end

defmodule BenchCompiled.A do
  @behaviour BenchCompiled

  @impl BenchCompiled
  def some_function, do: false
end

defmodule BenchCompiled.B do
  @behaviour BenchCompiled

  @impl BenchCompiled
  def some_function, do: true
end

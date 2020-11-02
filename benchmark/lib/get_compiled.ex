defmodule BenchGetCompiled do
  use Adapter, default: BenchGetCompiled.A, mode: :get_compiled, log: false, validate: false

  behavior do
    @doc ~S"Some docs"
    @callback some_function :: boolean
  end
end

defmodule BenchGetCompiled.A do
  @behaviour BenchGetCompiled

  @impl BenchGetCompiled
  def some_function, do: false
end

defmodule BenchGetCompiled.B do
  @behaviour BenchGetCompiled

  @impl BenchGetCompiled
  def some_function, do: true
end

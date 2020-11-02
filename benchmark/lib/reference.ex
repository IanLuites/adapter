defmodule BenchReference do
  @doc ~S"Some docs"
  @callback some_function :: boolean

  @spec some_function :: boolean
  def some_function,
    do: Application.get_env(:benchmark, :reference, BenchReference.A).some_function()
end

defmodule BenchReference.A do
  @behaviour BenchReference

  @impl BenchReference
  def some_function, do: false
end

defmodule BenchReference.B do
  @behaviour BenchReference

  @impl BenchReference
  def some_function, do: true
end

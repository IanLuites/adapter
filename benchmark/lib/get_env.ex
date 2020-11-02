defmodule BenchGetEnv do
  use Adapter, default: BenchGetEnv.A, mode: :get_env, log: false, validate: false

  behavior do
    @doc ~S"Some docs"
    @callback some_function :: boolean
  end
end

defmodule BenchGetEnv.A do
  @behaviour BenchGetEnv

  @impl BenchGetEnv
  def some_function, do: false
end

defmodule BenchGetEnv.B do
  @behaviour BenchGetEnv

  @impl BenchGetEnv
  def some_function, do: true
end

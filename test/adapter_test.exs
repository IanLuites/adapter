defmodule AdapterTest do
  use ExUnit.Case

  test "only allows valid modes" do
    assert_raise CompileError, fn ->
      Code.compile_quoted(
        quote do
          defmodule InvalidMode do
            use Adapter, mode: :flurp

            behaviour do
              @doc ~S"A color's RGB value."
              @callback rgb :: {0..255, 0..255, 0..255}
            end

            def red, do: elem(rgb(), 0)
          end
        end
      )
    end
  end

  defmodule Storage do
    use Adapter, validate: true

    behavior do
      @doc ~S"Store an item"
      @callback store(item :: term) :: :ok | {:error, atom}

      @doc ~S"Delete an item"
      @callback delete(term) :: :ok | {:error, atom}
    end
  end

  defmodule PostgreSQL do
    @behaviour Storage

    @impl Storage
    def store(item)
    def store(_), do: :ok

    @impl Storage
    def delete(item)
    def delete(_), do: :ok
  end

  defmodule Redis do
    @behaviour Storage

    @impl Storage
    def store(item)
    def store(_), do: :ok

    @impl Storage
    def delete
    def delete, do: :ok
  end

  test "validates adapters" do
    assert Storage.configure(PostgreSQL) == :ok
    assert Storage.configure(Redis) == {:error, :invalid_adapter_implementation}
  end
end

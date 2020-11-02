defmodule Adapter.GetEnvTest do
  use ExUnit.Case

  defmodule Color do
    use Adapter, mode: :get_env, default: Adapter.GetEnvTest.Blue

    behavior do
      @doc ~S"A color's RGB value."
      @callback rgb :: {0..255, 0..255, 0..255}
    end

    def red, do: elem(rgb(), 0)
  end

  defmodule Red do
    @behaviour Color

    @impl Color
    def rgb, do: {255, 0, 0}
  end

  defmodule Green do
    @behaviour Color

    @impl Color
    def rgb, do: {0, 255, 0}
  end

  defmodule Blue do
    @behaviour Color

    @impl Color
    def rgb, do: {0, 0, 255}
  end

  test "allow switching adapters" do
    # Check default
    assert Color.rgb() == Blue.rgb()
    assert Color.red() == elem(Blue.rgb(), 0)

    # Check adapter changes
    Enum.each([Red, Green, Blue], fn c ->
      assert Color.configure(c) == :ok
      assert Color.rgb() == c.rgb()
      assert Color.red() == elem(c.rgb(), 0)
    end)
  end

  describe "not configured returns" do
    test "auto generated error" do
      mod = generate_module([])
      id = mod |> Module.split() |> List.last()
      assert mod.rgb() == {:error, :"#{id}_not_configured"}
    end

    test "set error" do
      mod = generate_module(error: :custom_error)
      assert mod.rgb() == {:error, :custom_error}
    end

    test "raises" do
      mod = generate_module(error: :raise)
      assert_raise RuntimeError, &mod.rgb/0
    end

    test "set error, no random" do
      mod = generate_module(error: :custom_error, random: false)
      assert mod.rgb() == {:error, :custom_error}
    end

    test "raises, no random" do
      mod = generate_module(error: :raise, random: false)
      assert_raise RuntimeError, &mod.rgb/0
    end
  end

  defp generate_module(opts) do
    mod = Module.concat([__MODULE__, Color, to_string(Enum.random(0..10_000_000))])

    Code.compile_quoted(
      quote do
        defmodule unquote(mod) do
          use Adapter, unquote([{:mode, :get_env} | opts])

          behaviour do
            @doc ~S"A color's RGB value."
            @callback rgb :: {0..255, 0..255, 0..255}
          end

          def red, do: elem(rgb(), 0)
        end
      end
    )

    mod
  end
end

defmodule Color do
  use Adapter, default: Blue

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

defmodule Adapterized do
  @moduledoc """
  Documentation for `Adapterized`.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Adapterized.hello()
      :world

  """
  def hello do
    if Color.rgb() == {0, 0, 255} and
         Color.red() == 0 and
         Storage.type() == :cache and
         Storage.persistent?() == false do
      :ok
    end
  end
end

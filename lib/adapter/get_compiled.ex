defmodule Adapter.GetCompiled do
  @moduledoc false

  @doc false
  @spec generate(term, Adapter.Utility.behavior(), Adapter.Utility.config()) :: term
  def generate(code, callbacks, config)

  def generate(code, callbacks, config) do
    %{app: app, default: default, error: error, key: key, random: random} = config

    err = Adapter.Utility.generate_error(error, random)

    quote do
      @adapter Application.get_env(unquote(app), unquote(key), unquote(default))

      unquote(code)

      if @adapter do
        unquote(generate_implementation(callbacks))
      else
        require Logger

        Logger.warn(fn ->
          """
          [Adapter] #{inspect(__MODULE__)} is not configured.
              Mode `:get_compiled` adapters can not be changed at runtime.
              Use `mode: :compile` or `mode: :get_env` to allow runtime reconfiguration.
          """
        end)

        unquote(generate_errors(callbacks, err))
      end

      @doc false
      @spec __adapter__ :: module | nil
      def __adapter__, do: @adapter

      @doc ~S"""
      Configure a new adapter implementation.

      ## Example

      ```elixir
      iex> configure(Fake)
      :ok
      ```
      """
      @spec configure(module) :: :ok
      def configure(adapter)

      def configure(_) do
        raise "An adapter configured with `:get_compiled` can't be changed at runtime."
      end
    end
  end

  @spec generate_errors(Adapter.Utility.behavior(), term) :: term
  defp generate_errors(callbacks, error) do
    Enum.reduce(callbacks, nil, fn {key, %{spec: s, doc: d, args: a}}, acc ->
      vars = Enum.map(a, &Macro.var(&1, nil))
      u_vars = Enum.map(a, &Macro.var(:"_#{&1}", nil))

      quote do
        unquote(acc)

        unquote(d)
        unquote(s)
        def unquote(key)(unquote_splicing(vars))
        def unquote(key)(unquote_splicing(u_vars)), do: unquote(error)
      end
    end)
  end

  @spec generate_implementation(Adapter.Utility.behavior()) :: term
  defp generate_implementation(callbacks) do
    Enum.reduce(callbacks, nil, fn {key, %{spec: s, doc: d, args: a}}, acc ->
      vars = Enum.map(a, &Macro.var(&1, nil))

      quote do
        unquote(acc)

        unquote(d)
        unquote(s)
        def unquote(key)(unquote_splicing(vars))

        def unquote(key)(unquote_splicing(vars)),
          do: @adapter.unquote(key)(unquote_splicing(vars))
      end
    end)
  end
end

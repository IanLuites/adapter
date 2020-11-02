defmodule Adapter.GetEnv do
  @moduledoc false

  @doc false
  @spec generate(term, Adapter.Utility.behavior(), Adapter.Utility.config()) :: term
  def generate(code, callbacks, config)

  def generate(code, callbacks, config) do
    %{
      app: app,
      default: default,
      error: error,
      key: key,
      log: log,
      validate: validate
    } = config

    err =
      if error == :raise do
        quote do: raise("#{__MODULE__} not configured.")
      else
        quote do: {:error, unquote(error)}
      end

    quote do
      unquote(code)
      unquote(generate_implementation(callbacks, err))

      @doc false
      @spec __adapter__ :: module | nil
      def __adapter__, do: Application.get_env(unquote(app), unquote(key), unquote(default))

      @doc ~S"""
      Configure a new adapter implementation.

      ## Example

      ```elixir
      iex> configure(Fake)
      :ok
      ```
      """
      @spec configure(module) :: :ok
      def configure(adapter) do
        with false <- __adapter__() == adapter && :ok,
             :ok <-
               unquote(
                 Adapter.Utility.generate_validation(
                   validate,
                   callbacks,
                   Macro.var(:adapter, __MODULE__)
                 )
               ) do
          Application.put_env(unquote(app), unquote(key), adapter, persistent: true)
          unquote(Adapter.Utility.generate_logger(log, Macro.var(:adapter, __MODULE__)))
          :ok
        end
      end
    end
  end

  @spec generate_implementation(Adapter.Utility.behavior(), term) :: term
  defp generate_implementation(callbacks, error) do
    Enum.reduce(callbacks, nil, fn {key, %{spec: s, doc: d, args: a}}, acc ->
      vars = Enum.map(a, &Macro.var(&1, nil))

      quote do
        unquote(acc)

        unquote(d)
        unquote(s)
        def unquote(key)(unquote_splicing(vars))

        def unquote(key)(unquote_splicing(vars)) do
          if adapter = __adapter__(),
            do: adapter.unquote(key)(unquote_splicing(vars)),
            else: unquote(error)
        end
      end
    end)
  end
end

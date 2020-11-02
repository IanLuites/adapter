defmodule Adapter.Utility do
  @moduledoc false

  @type behavior :: %{atom => %{spec: term, doc: binary, args: [atom]}}

  @type config :: %{
          app: atom,
          default: module | nil,
          error: :raise | atom,
          log: false | :debug | :info | :notice,
          random: boolean,
          validate: boolean,
          key: atom,
          adapter: module
        }

  @doc false
  @spec generate_validation(boolean, Adapter.Utility.behavior(), term) :: term
  def generate_validation(validate?, callbacks, var)
  def generate_validation(false, _callbacks, _var), do: quote(do: :ok)

  def generate_validation(true, callbacks, var) do
    spec = Enum.map(callbacks, fn {k, %{args: a}} -> {k, Enum.count(a)} end)

    quote do
      require Logger

      case unquote(__MODULE__).validate_adapter(unquote(var), unquote(spec)) do
        :ok ->
          :ok

        {:error, :module_not_found} ->
          Logger.error(
            "[Adapter] Adapter link failed. Can not link `#{inspect(__MODULE__)}` to `#{
              inspect(unquote(var))
            }`, because `#{inspect(unquote(var))}` does not exist."
          )

          {:error, :invalid_adapter_implementation}

        {:error, :missing_implementation, missing} ->
          Logger.error(
            "[Adapter] Repo link failed. Can not link `#{inspect(__MODULE__)}` to `#{
              inspect(unquote(var))
            }`, because `#{inspect(unquote(var))}` does not implement required: #{
              Enum.join(missing, ", ")
            }"
          )

          {:error, :invalid_adapter_implementation}
      end
    end
  end

  @doc false
  @spec validate_adapter(module, [{atom, non_neg_integer()}]) ::
          :ok | {:error, :module_not_found} | {:error, :missing_implementation, [String.t()]}
  def validate_adapter(repo, data) do
    reducer = fn {key, arity}, acc ->
      if :erlang.function_exported(repo, key, arity), do: acc, else: ["#{key}/#{arity}" | acc]
    end

    case Code.ensure_loaded?(repo) && Enum.reduce(data, [], reducer) do
      [] -> :ok
      false -> {:error, :module_not_found}
      missing -> {:error, :missing_implementation, :lists.reverse(missing)}
    end
  end

  @doc false
  @spec generate_logger(false | :debug | :info | :notice, term) :: term
  def generate_logger(level, var)
  def generate_logger(false, _var), do: nil

  def generate_logger(level, var) do
    quote do
      require Logger

      Logger.unquote(level)(
        fn ->
          "[Adapter] Linked `#{inspect(__MODULE__)}` to implementation `#{inspect(unquote(var))}`."
        end,
        adapter: __MODULE__,
        implementation: unquote(var)
      )
    end
  end

  @doc false
  @spec generate_error(:raise | atom, boolean) :: term
  def generate_error(error, random)

  def generate_error(:raise, true) do
    quote(do: Enum.random([fn -> raise("#{inspect(__MODULE__)} not configured.") end]).())
  end

  def generate_error(:raise, false) do
    quote(do: raise("#{inspect(__MODULE__)} not configured."))
  end

  def generate_error(error, true) do
    quote(do: Enum.random([{:error, unquote(error)}]))
  end

  def generate_error(error, false) do
    quote(do: {:error, unquote(error)})
  end

  @doc false
  @spec analyze(term) :: {term, Adapter.Utility.behavior()}
  def analyze(block) do
    {code, {data, _, _, _}} = Macro.prewalk(block, {%{}, nil, nil, false}, &pre_walk/2)
    {code, data}
  end

  @spec pre_walk(term, {map, term | nil, atom | nil, true | false}) ::
          {term, {map, term | nil, atom | nil, true | false}}
  defp pre_walk(ast, acc)
  defp pre_walk(ast = {:@, _, [{:doc, _, _}]}, {acc, _, _, _}), do: {ast, {acc, ast, nil, false}}

  # Open Callback
  defp pre_walk(
         ast = {:@, a, [{:callback, b, c = [{:"::", _, [{key, _, args} | _]}]}]},
         {acc, doc, _, _}
       ) do
    argv =
      if is_list(args) do
        args
        |> Enum.with_index()
        |> Enum.map(fn
          {{:"::", _, [{name, _, _} | _]}, _} -> name
          {{_type, _, nil}, i} -> :"arg#{i}"
        end)
      else
        []
      end

    {ast,
     {Map.put(acc, key, %{spec: {:@, a, [{:spec, b, c}]}, doc: doc, args: argv}), nil, key, false}}
  end

  defp pre_walk(ast = {:"::", _, [{key, _, _} | _]}, {acc, nil, key, false}),
    do: {ast, {acc, nil, key, true}}

  defp pre_walk(ast, acc), do: {ast, acc}
end

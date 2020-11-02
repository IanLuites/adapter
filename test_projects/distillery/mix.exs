defmodule Adapterized.MixProject do
  use Mix.Project

  def project do
    [
      app: :adapterized,
      version: "0.1.0",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger, :ex_unit],
      mod: {Adapterized.Application, []}
    ]
  end

  defp deps do
    [
      {:adapter, path: "../../"},
      {:distillery, "~> 2.1"}
    ]
  end
end

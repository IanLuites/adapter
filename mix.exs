defmodule Adapter.MixProject do
  use Mix.Project

  @version "1.0.0-rc0"

  def project do
    [
      app: :adapter,
      version: @version,
      description: "Fast adapters with clear syntax and build-in safety.",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      elixirc_paths: ["lib" | if(Mix.env() == :test, do: ["test/support"], else: [])],
      deps: deps(),
      package: package(),

      # Testing
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ],
      dialyzer: [ignore_warnings: ".dialyzer", plt_add_deps: true, plt_add_apps: [:compiler]],

      # Docs
      name: "Adapter",
      source_url: "https://github.com/IanLuites/adapter",
      homepage_url: "https://github.com/IanLuites/adapter",
      docs: [
        main: "readme",
        extras: ["README.md"],
        source_ref: "v#{@version}",
        source_url: "https://github.com/IanLuites/adapter"
      ]
    ]
  end

  def package do
    [
      name: :adapter,
      maintainers: ["Ian Luites"],
      licenses: ["MIT"],
      files: [
        # Elixir
        "lib/adapter",
        "lib/adapter.ex",
        ".formatter.exs",
        "mix.exs",
        "README*",
        "LICENSE*"
      ],
      links: %{
        "GitHub" => "https://github.com/IanLuites/adapter"
      }
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:heimdallr, ">= 0.0.0", only: [:dev, :test]}
    ]
  end
end

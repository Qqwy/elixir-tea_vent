defmodule TeaVent.MixProject do
  use Mix.Project

  @version "0.1.1"
  @repo_url "https://github.com/Qqwy/elixir-tea_vent"

  def project do
    [
      app: :tea_vent,
      version: @version,
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package(),
      description: description(),
      source_url: @repo_url,

      # Docs
      name: "TeaVent",
      docs: [
        source_ref: "v#{@version}",
        main: "TeaVent",
        source_url: @repo_url
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"},
      {:dialyxir, "~> 1.0.0-rc.4", only: [:dev], runtime: false},
      {:credo, "~> 1.5.5", only: [:dev, :test], runtime: false},
      {:ex_doc, ">= 0.0.0", only: :dev}
    ]
  end

  defp package() do
    [
      # These are the default files included in the package
      maintainers: ["Wiebe-Marten Wijnja/Qqwy"],
      files: ~w(lib .formatter.exs mix.exs README* ),
      licenses: ["MIT"],
      links: %{
        "GitHub" => @repo_url
      }
    ]
  end

  defp description() do
    "Perform Event dispatching in an Event Sourcing and The Elm Architecture (TEA)-like style."
  end
end

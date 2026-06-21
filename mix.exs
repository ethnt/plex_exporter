defmodule PrometheusPlexExporter.MixProject do
  use Mix.Project

  def project do
    [
      app: :plex_exporter,
      version: "0.0.2",
      elixir: "~> 1.18",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      releases: releases(),
      dialyzer: dialyzer()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {PlexExporter.Application, []},
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:bandit, "~> 1.0"},
      {:castore, "~> 1.0"},
      {:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false},
      {:logger_json, "~> 7.0.4"},
      {:mimic, "~> 2.3.0", only: [:test]},
      {:prometheus_plugs, git: "https://github.com/ethnt/prometheus-plugs.git", ref: "36e7dc7"},
      {:req, "~> 0.5.0"},
      {:styler, "~> 1.11", only: [:dev, :test], runtime: false}
    ]
  end

  def releases do
    [
      plex_exporter: [
        include_executables_for: [:unix]
      ]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp dialyzer do
    [
      plt_add_apps: [:mix],
      plt_core_path: "priv/plts",
      plt_file: {:no_warn, "priv/plts/plex_exporter.plt"},
      format: "dialyxir"
    ]
  end
end

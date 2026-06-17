defmodule PrometheusPlexExporter.MixProject do
  use Mix.Project

  def project do
    [
      app: :plex_exporter,
      version: "0.1.0",
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      dialyzer: dialyzer()
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
      {:req, "~> 0.5.0"},
      {:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false}
    ]
  end

  defp dialyzer do
    [
      plt_add_apps: [:mix],
      plt_core_path: "priv/plts",
      plt_file: {:no_warn, "priv/plts/plex_exporter.plt"},
      format: "dialyxir"
    ]
  end
end

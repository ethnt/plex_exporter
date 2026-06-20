defmodule PlexExporter.Application do
  @moduledoc false

  use Application

  @impl Application
  def start(_type, _args) do
    PlexExporter.Plug.setup()
    PlexExporter.Metrics.init()

    if Application.get_env(:plex_exporter, :env) != :test do
      PlexExporter.Config.validate!()
    end

    Supervisor.start_link(children(), strategy: :one_for_one)
  end

  defp children do
    case Application.get_env(:plex_exporter, :env) do
      :test ->
        []

      _ ->
        [
          PlexExporter.Worker,
          {Bandit, plug: PlexExporter.Router, port: PlexExporter.Config.port()}
        ]
    end
  end
end

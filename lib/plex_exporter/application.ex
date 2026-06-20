defmodule PlexExporter.Application do
  use Application

  @impl Application
  def start(_type, _args) do
    PlexExporter.Plug.setup()
    PlexExporter.Metrics.init()

    Supervisor.start_link(children(), strategy: :one_for_one)
  end

  defp children do
    case Mix.env() do
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

defmodule PlexExporter.Application do
  use Application

  @impl Application
  def start(_type, _args) do
    PlexExporter.Plug.setup()
    PlexExporter.Metrics.setup()

    children = [
      PlexExporter.Worker,
      {Bandit, plug: PlexExporter.Router, port: 9000}
    ]

    Supervisor.start_link(children, strategy: :one_for_one)
  end
end

defmodule PlexExporter.Metrics.PlexTotalSessions do
  @moduledoc """
  Metric for session counts
  """

  @behaviour PlexExporter.Metrics.Metric

  use PlexExporter.Metrics.Metric

  alias PlexExporter.Collectors

  @impl true
  def init do
    Gauge.declare(
      name: :plex_total_sessions,
      labels: [:type],
      help: "Number of active Plex sessions"
    )

    :ok
  end

  @impl true
  def update do
    case Collectors.Sessions.count() do
      :error ->
        :error

      {:ok, counts} ->
        Enum.each(counts, fn {type, count} ->
          Gauge.set([name: :plex_total_sessions, labels: [type]], count)
        end)

        :ok
    end
  end
end

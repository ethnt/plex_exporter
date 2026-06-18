defmodule PlexExporter.Metrics do
  use Prometheus.Metric

  alias PlexExporter.Data

  def setup do
    Gauge.declare(
      name: :plex_total_sessions,
      labels: [:type],
      help: "Number of active Plex sessions"
    )

    Gauge.declare(
      name: :plex_library_items,
      labels: [:name],
      help: "Number of Plex library items"
    )
  end

  def update_metrics! do
    update_plex_total_sessions!()
    update_plex_library_items!()
  end

  def update_plex_total_sessions! do
    case Data.Sessions.count() do
      :error ->
        :ok

      {:ok, counts} ->
        Enum.each(counts, fn {type, count} ->
          Gauge.set([name: :plex_total_sessions, labels: [type]], count)
        end)
    end
  end

  def update_plex_library_items! do
    case Data.Media.count() do
      {:ok, counts} ->
        Enum.each(counts, fn {library, count} ->
          Gauge.set([name: :plex_library_items, labels: [library]], count)
        end)
    end
  end
end

defmodule PlexExporter.Metrics do
  @moduledoc """
  Prometheus gauges and metrics
  """

  alias PlexExporter.Metrics

  @metrics [
    Metrics.PlexTotalSessions,
    Metrics.PlexLibraryItems
  ]

  def init do
    Enum.each(@metrics, fn metric -> metric.init() end)
  end

  def update do
    Enum.each(@metrics, fn metric -> metric.update() end)
  end
end

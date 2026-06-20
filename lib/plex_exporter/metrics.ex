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
    Enum.reduce_while(@metrics, :ok, fn metric, _acc ->
      case metric.update() do
        {:error, reason} when reason in [:unauthorized, :forbidden] -> {:halt, {:error, reason}}
        _ -> {:cont, :ok}
      end
    end)
  end
end

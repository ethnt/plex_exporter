defmodule PlexExporter.Metrics do
  @moduledoc """
  Prometheus gauges and metrics
  """

  alias PlexExporter.Metrics

  @metrics [
    Metrics.PlexActiveSessions,
    Metrics.PlexLibraryItems,
    Metrics.PlexServer
  ]

  @doc """
  Initialize all metrics
  """
  @spec init :: any()
  def init do
    Enum.each(@metrics, fn metric -> metric.init() end)
  end

  @doc """
  Update metrics. If no mode is provided, then all metrics will be updated
  """
  @spec update(:instant | :cached | nil) :: any()
  def update(mode \\ nil) do
    @metrics
    |> Enum.filter(fn metric -> is_nil(mode) or metric.mode() == mode end)
    |> Enum.reduce_while(:ok, fn metric, _acc ->
      case metric.update() do
        {:error, reason} when reason in [:unauthorized, :forbidden] -> {:halt, {:error, reason}}
        _ -> {:cont, :ok}
      end
    end)
  end
end

defmodule PlexExporter.Metrics.Metric do
  @moduledoc """
  Behaviour for an exposed metric, requiring `init/0` and `update/0` functions
  """

  @callback init :: :ok | :error
  @callback update :: :ok | :error

  defmacro __using__(_opts) do
    quote do
      use Prometheus.Metric
    end
  end
end

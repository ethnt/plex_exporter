defmodule PlexExporter.Metrics.Metric do
  @callback init :: :ok
  @callback update :: :ok | :error

  defmacro __using__(_opts) do
    quote do
      use Prometheus.Metric
    end
  end
end

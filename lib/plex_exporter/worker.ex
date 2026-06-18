defmodule PlexExporter.Worker do
  @moduledoc """
  Polls the API to update the metrics
  """

  use GenServer

  @poll_interval :timer.seconds(10)

  def start_link(_), do: GenServer.start_link(PlexExporter.Worker, %{})

  def init(state) do
    PlexExporter.Metrics.update_metrics!()
    schedule_poll()
    {:ok, state}
  end

  def handle_info(:poll, state) do
    PlexExporter.Metrics.update_metrics!()
    schedule_poll()
    {:noreply, state}
  end

  defp schedule_poll do
    Process.send_after(self(), :poll, @poll_interval)
  end
end

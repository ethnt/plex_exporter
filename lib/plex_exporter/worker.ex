defmodule PlexExporter.Worker do
  @moduledoc """
  Polls the API to update the metrics
  """

  use GenServer

  require Logger

  @update_interval to_timeout(second: 10)

  def start_link(_), do: GenServer.start_link(PlexExporter.Worker, %{})

  def init(state) do
    send(self(), :update)
    {:ok, state}
  end

  def handle_info(:update, state) do
    case PlexExporter.Metrics.update() do
      {:error, reason} when reason in [:unauthorized, :forbidden] ->
        Logger.error("Plex returned #{reason}, verify your Plex token. Polling has stopped.")

      _ ->
        schedule_update()
    end

    {:noreply, state}
  end

  defp schedule_update do
    Process.send_after(self(), :update, @update_interval)
  end
end

defmodule PlexExporter.Worker do
  @moduledoc """
  Polls the API to update cached metrics
  """

  use GenServer

  require Logger

  def start_link(_), do: GenServer.start_link(PlexExporter.Worker, %{})

  def init(state) do
    send(self(), :update)
    {:ok, state}
  end

  def handle_info(:update, state) do
    Logger.debug("[Worker] Updating cached metrics")

    case PlexExporter.Metrics.update(:cached) do
      {:error, reason} when reason in [:unauthorized, :forbidden] ->
        Logger.error("[Worker] Plex returned #{reason}, verify your Plex token.")

      _ ->
        :ok
    end

    schedule_update()
    {:noreply, state}
  end

  defp schedule_update do
    Process.send_after(self(), :update, update_interval())
  end

  defp update_interval do
    to_timeout(second: String.to_integer(Application.get_env(:plex_exporter, :metrics_refresh_interval)))
  end
end

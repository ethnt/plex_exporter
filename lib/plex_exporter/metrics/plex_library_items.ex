defmodule PlexExporter.Metrics.PlexLibraryItems do
  @moduledoc """
  Metric for session counts
  """

  @behaviour PlexExporter.Metrics.Metric

  use PlexExporter.Metrics.Metric

  alias PlexExporter.Collectors

  @impl true
  def init do
    Gauge.declare(
      name: :plex_library_items,
      labels: [:title, :type],
      help: "Number of Plex library items"
    )

    :ok
  end

  @impl true
  def update do
    case Collectors.Media.count() do
      {:ok, counts} ->
        Enum.each(counts, fn %{title: title, type: type, count: count} ->
          Gauge.set([name: :plex_library_items, labels: [title, type]], count)
        end)

      {:error, reason} ->
        {:error, reason}
    end
  end
end

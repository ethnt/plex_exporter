defmodule PlexExporter.Collectors.Media do
  @moduledoc """
  Metrics about media
  """

  alias PlexExporter.Plex

  @type section_metrics :: %{title: String.t(), type: String.t(), count: non_neg_integer()}

  @doc """
  Return metrics about the library
  """
  @spec count :: {:ok, [section_metrics()]} | :error
  def count do
    case Plex.Library.sections() do
      {:ok, response} ->
        sections = get_in(response.body, ["MediaContainer", "Directory"]) || []

        values =
          sections
          |> Enum.flat_map(&section_value/1)

        {:ok, values}

      _ ->
        :error
    end
  end

  @spec section_value(map()) :: [section_metrics()]
  defp section_value(%{"title" => title, "key" => key, "type" => "show"}) do
    {:ok, count} = section_count(key)
    {:ok, episode_count} = section_count(key, %{"type" => "4"})

    [
      %{title: title, type: "show", count: count},
      %{title: "#{title} - Episodes", type: "show_episode", count: episode_count}
    ]
  end

  defp section_value(%{"title" => title, "key" => key, "type" => type}) do
    {:ok, count} = section_count(key)
    [%{title: title, type: type, count: count}]
  end

  @spec section_count(String.t(), map()) :: {:ok, non_neg_integer() | nil}
  defp section_count(section_id, params \\ %{}) do
    with {:ok, response} <- Plex.Library.section(section_id, params: params, offset: 0, limit: 0),
         {:ok, [count]} <- Map.fetch(response.headers, "x-plex-container-total-size") do
      {:ok, String.to_integer(count)}
    else
      _ -> {:ok, nil}
    end
  end
end

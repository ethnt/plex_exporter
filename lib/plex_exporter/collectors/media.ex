defmodule PlexExporter.Collectors.Media do
  @moduledoc """
  Metrics about media
  """

  alias PlexExporter.Plex

  @spec count :: {:ok, %{String.t() => non_neg_integer() | nil}} | :error
  def count do
    case Plex.Library.sections() do
      {:ok, response} ->
        sections = get_in(response.body, ["MediaContainer", "Directory"]) || []

        values =
          sections
          |> Enum.flat_map(&section_value/1)
          |> Map.new()

        {:ok, values}

      _ ->
        :error
    end
  end

  @spec section_value(map()) :: list({String.t(), non_neg_integer()})
  defp section_value(%{"title" => title, "key" => key, "type" => "show"}) do
    {:ok, count} = section_count(key)
    {:ok, episode_count} = section_count(key, %{"type" => "4"})
    [{title, count}, {"#{title} - Episodes", episode_count}]
  end

  defp section_value(%{"title" => title, "key" => key}) do
    {:ok, count} = section_count(key)
    [{title, count}]
  end

  @spec section_count(String.t(), map()) :: {:ok, non_neg_integer() | nil}
  def section_count(section_id, params \\ %{}) do
    with {:ok, response} <- Plex.Library.section(section_id, params: params, offset: 0, limit: 0),
         {:ok, [count]} <- Map.fetch(response.headers, "x-plex-container-total-size") do
      {:ok, String.to_integer(count)}
    else
      _ -> {:ok, nil}
    end
  end
end

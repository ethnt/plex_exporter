defmodule PlexExporter.Metrics.Media do
  @moduledoc """
  Metrics about media
  """

  alias PlexExporter.Config
  alias PlexExporter.Plex.Client, as: Plex

  @doc """
  Count number of pieces of media in each library
  """
  @spec count(Config.t()) :: {:ok, %{required(String.t()) => non_neg_integer()}} | :error
  def count(config) do
    case Plex.list_library_sections(config, %{}) do
      {:ok, response} ->
        %{"MediaContainer" => %{"Directory" => sections}} = response.body

        result =
          Enum.reduce(sections, %{}, fn section, acc ->
            %{"title" => title, "key" => key, "type" => type} = section
            count = section_count(config, key)

            acc = Map.merge(acc, %{title => count})

            if type == "show" do
              episode_count = section_count(config, key, %{"type" => "4"})

              Map.merge(acc, %{"#{title} - Episodes" => episode_count})
            else
              acc
            end
          end)

        {:ok, result}

      _ ->
        :error
    end
  end

  @spec section_count(Config.t(), String.t(), Plex.params()) :: non_neg_integer()
  defp section_count(config, section_id, params \\ %{}) do
    # We only need the total -- if we provide pagination headers, but set them both to `0`, we prevent
    # fetching actual information, but still get a total in a header
    {:ok, response} =
      Plex.list_library_section_items(config, section_id, params, offset: 0, limit: 0)

    case Map.fetch(response.headers, "x-plex-container-total-size") do
      {:ok, [count]} -> String.to_integer(count)
      _ -> 0
    end
  end
end

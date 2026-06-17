defmodule PlexExporter.Metrics.Media do
  @moduledoc """
  Metrics about media
  """

  alias PlexExporter.Config
  alias PlexExporter.Plex.Client, as: Plex

  @spec count(Config.t()) :: {:ok, %{required(String.t()) => non_neg_integer()}} | :error
  def count(config) do
    case Plex.list_library_sections(config) do
      {:ok, response} ->
        %{"MediaContainer" => %{"Directory" => sections}} = response.body

        {:ok,
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
         end)}

      _ ->
        :error
    end
  end

  @spec section_count(Config.t(), integer()) :: non_neg_integer()
  @spec section_count(Config.t(), integer(), map()) :: non_neg_integer()
  defp section_count(config, section_id, params \\ %{}) do
    {:ok, response} = Plex.list_library_section_items(config, section_id, params)

    [count] = response.headers["x-plex-container-total-size"]

    String.to_integer(count)
  end
end

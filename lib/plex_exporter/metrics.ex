defmodule PlexExporter.Metrics do
  @moduledoc """
  Functions to fetch metrics to export
  """

  alias PlexExporter.Config
  alias PlexExporter.Plex

  @doc """
  Count number of sessions, broken down by type of session
  """
  @spec session_count(Config.t()) :: %{
          direct_play: non_neg_integer(),
          direct_stream: non_neg_integer(),
          transcode: non_neg_integer()
        }
  def session_count(config) do
    {:ok, response} = Plex.list_sessions(config)

    Enum.reduce(
      response.body["MediaContainer"]["Metadata"],
      %{direct_play: 0, direct_stream: 0, transcode: 0},
      fn stream, acc ->
        case stream do
          %{"Media" => [%{"Part" => [%{"decision" => "directplay"}]}]} ->
            Map.merge(acc, %{direct_play: Map.get(acc, :direct_play) + 1})

          %{
            "TranscodeSession" => %{"videoDecision" => "copy"},
            "Media" => [%{"Part" => [%{"decision" => "directStream"}]}]
          } ->
            Map.merge(acc, %{direct_stream: Map.get(acc, :direct_stream) + 1})

          %{"TranscodeSession" => %{"videoDecision" => "transcode"}} ->
            Map.merge(acc, %{transcode: Map.get(acc, :transcode) + 1})

          _ ->
            IO.puts("does not match")
            acc
        end
      end
    )
  end

  @doc """
  Count media in the library, broken down by section
  """
  @spec media_count(Config.t()) :: %{required(String.t()) => non_neg_integer()}
  def media_count(config) do
    {:ok, response} = Plex.list_library_sections(config)

    %{"MediaContainer" => %{"Directory" => sections}} = response.body

    Enum.reduce(sections, %{}, fn section, acc ->
      %{"title" => title, "key" => key, "type" => type} = section

      count = media_section_count(config, key)

      acc = Map.merge(acc, %{title => count})

      if type == "show" do
        episode_count = media_section_count(config, key, %{"type" => "4"})

        Map.merge(acc, %{"#{title} - Episodes" => episode_count})
      else
        acc
      end
    end)
  end

  defp media_section_count(config, section_id, params \\ %{}) do
    {:ok, response} = Plex.list_library_section_items(config, section_id, params)

    [count] = response.headers["x-plex-container-total-size"]

    String.to_integer(count)
  end
end

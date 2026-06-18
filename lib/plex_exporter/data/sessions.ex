defmodule PlexExporter.Data.Sessions do
  @moduledoc """
  Metrics about sessions
  """

  alias PlexExporter.Plex.Client, as: Plex

  @doc """
  Count number of sessions, broken down by type of session
  """
  @spec count() ::
          {:ok,
           %{
             direct_play: non_neg_integer(),
             direct_stream: non_neg_integer(),
             transcode: non_neg_integer()
           }}
          | :error
  def count do
    case Plex.get("/status/sessions") do
      {:ok, response} ->
        streams = response.body["MediaContainer"]["Metadata"] || []

        tally =
          streams
          |> Enum.map(fn stream -> stream_type(stream) end)
          |> Enum.frequencies()

        {:ok, Map.merge(%{direct_play: 0, direct_stream: 0, transcode: 0}, tally)}

      _ ->
        :error
    end
  end

  @spec stream_type(map()) :: :direct_play | :direct_stream | :transcode | :unknown
  defp stream_type(%{"Media" => [%{"Part" => [%{"decision" => "directplay"}]}]}),
    do: :direct_play

  defp stream_type(%{
         "TranscodeSession" => %{"videoDecision" => "copy"},
         "Media" => [%{"Part" => [%{"decision" => "directStream"}]}]
       }),
       do: :direct_stream

  defp stream_type(%{"TranscodeSession" => %{"videoDecision" => "transcode"}}), do: :unknown

  defp stream_type(_), do: :unknown
end

defmodule PlexExporter.Collectors.Sessions do
  @moduledoc """
  Metrics about sessions
  """

  alias PlexExporter.Plex

  @doc """
  Return tally of sessions based on type
  """
  @spec count ::
          {:ok,
           %{
             direct_play: non_neg_integer(),
             direct_stream: non_neg_integer(),
             transcode: non_neg_integer(),
             unknown: non_neg_integer()
           }}
          | :error
  def count do
    default_values = %{direct_play: 0, direct_stream: 0, transcode: 0}

    case Plex.Status.sessions() do
      {:ok, response} ->
        streams = get_in(response.body, ["MediaContainer", "Metadata"]) || []

        values =
          streams
          |> Enum.map(&stream_type/1)
          |> Enum.frequencies()

        {:ok, Map.merge(default_values, values)}

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

  defp stream_type(%{"TranscodeSession" => %{"videoDecision" => "transcode"}}), do: :transcode

  defp stream_type(_), do: :unknown
end

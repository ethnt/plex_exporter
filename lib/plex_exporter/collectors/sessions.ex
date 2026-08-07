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
          | {:error, atom()}
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

      {:error, reason} ->
        {:error, reason}
    end
  end

  @spec stream_type(map()) :: :direct_play | :direct_stream | :transcode | :unknown
  defp stream_type(session) do
    transcode = Map.get(session, "TranscodeSession")
    video = transcode && Map.get(transcode, "videoDecision")
    audio = transcode && Map.get(transcode, "audioDecision")

    cond do
      video == "transcode" or audio == "transcode" ->
        :transcode

      is_map(transcode) ->
        :direct_stream

      has_media?(session) ->
        :direct_play

      true ->
        :unknown
    end
  end

  @spec has_media?(map()) :: boolean()
  defp has_media?(%{"Media" => [_ | _]}), do: true
  defp has_media?(_), do: false
end

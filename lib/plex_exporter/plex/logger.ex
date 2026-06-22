defmodule PlexExporter.Plex.Logger do
  @moduledoc false
  require Logger

  def handle_event(
        [:req, :request, :pipeline, :stop],
        %{duration: duration},
        %{url: url, method: method, status: status},
        _config
      ) do
    ms = System.convert_time_unit(duration, :native, :millisecond)
    method = method |> to_string() |> String.upcase()
    Logger.debug(%{component: "plex", method: method, url: to_string(url), status: status, duration_ms: ms})
  end

  def handle_event(
        [:req, :request, :pipeline, :error],
        %{duration: duration},
        %{url: url, method: method, error: error},
        _config
      ) do
    ms = System.convert_time_unit(duration, :native, :millisecond)
    method = method |> to_string() |> String.upcase()
    Logger.error(%{component: "plex", method: method, url: to_string(url), error: inspect(error), duration_ms: ms})
  end

  def handle_event(_, _, _, _), do: :ok
end

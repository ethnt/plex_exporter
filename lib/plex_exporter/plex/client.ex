defmodule PlexExporter.Plex.Client do
  @moduledoc """
  Client for the Plex API
  """

  @doc """
  Displays information about the server
  """
  def info(config) do
    config
    |> base_request()
    |> Req.get(url: "/info")
  end

  @doc """
  List currently playing sessions
  """
  def list_sessions(config) do
    config
    |> base_request()
    |> Req.get(url: "/status/sessions")
  end

  @doc """
  List library sections
  """
  def list_library_sections(config) do
    config
    |> base_request()
    |> Req.get(url: "/library/sections")
  end

  @doc """
  Get items for a specific section
  """
  def list_library_section_items(config, section_id, params \\ %{}, opts \\ []) do
    config
    |> base_request()
    |> put_pagination_headers(opts)
    |> Req.get(
      url: "/library/sections/:section_id/all",
      path_params: [section_id: section_id],
      params: params
    )
  end

  defp base_request(%PlexExporter.Config{url: url, token: token}) do
    Req.new(base_url: url)
    |> Req.Request.put_new_header("Accept", "application/json")
    |> Req.Request.put_new_header("X-Plex-Token", token)
  end

  defp put_pagination_headers(request, opts) do
    offset = Keyword.get(opts, :offset, 0)
    count = Keyword.get(opts, :count, 0)

    request
    |> Req.Request.put_new_header("X-Plex-Container-Start", to_string(offset))
    |> Req.Request.put_new_header("X-Plex-Container-Size", to_string(count))
  end
end

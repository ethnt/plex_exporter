defmodule PlexExporter.Plex.Client do
  @moduledoc """
  Client for the Plex API
  """

  alias PlexExporter.Config

  @typedoc """
  Extra parameters to pass to the request
  """
  @type params :: map()

  @typedoc """
  Options to pass to the request
  """
  @type opts :: [offset: integer(), limit: integer()]

  @doc """
  Displays information about the server
  """
  @spec info(Config.t(), params(), opts()) :: {:ok, Req.Response.t()} | {:error, Exception.t()}
  def info(config, params \\ %{}, opts \\ []) do
    config
    |> base_request(opts)
    |> Req.get(url: "/info", params: params)
  end

  @doc """
  List currently playing sessions
  """
  @spec list_sessions(Config.t(), params(), opts()) ::
          {:ok, Req.Response.t()} | {:error, Exception.t()}
  def list_sessions(config, params \\ %{}, opts \\ []) do
    config
    |> base_request(opts)
    |> Req.get(url: "/status/sessions", params: params)
  end

  @doc """
  List library sections
  """
  @spec list_library_sections(Config.t(), params(), opts()) ::
          {:ok, Req.Response.t()} | {:error, Exception.t()}
  def list_library_sections(config, params \\ %{}, opts \\ []) do
    config
    |> base_request(opts)
    |> Req.get(url: "/library/sections", params: params)
  end

  @doc """
  List items for a specific section
  """
  @spec list_library_section_items(Config.t(), String.t(), params(), opts()) ::
          {:ok, Req.Response.t()} | {:error, Exception.t()}
  def list_library_section_items(config, section_id, params \\ %{}, opts \\ []) do
    base_request(config, opts)
    |> Req.get(
      url: "/library/sections/:section_id/all",
      path_params: [section_id: section_id],
      params: params
    )
  end

  @spec base_request(Config.t(), opts()) :: Req.Request.t()
  defp base_request(%PlexExporter.Config{url: url, token: token}, opts) do
    req =
      Req.new(base_url: url)
      |> Req.Request.put_new_header("Accept", "application/json")
      |> Req.Request.put_new_header("X-Plex-Token", token)
      |> apply_options(opts)

    req
  end

  @spec apply_options(Req.Request.t(), opts()) :: Req.Request.t()
  defp apply_options(request, opts) do
    with {:ok, offset} <- Keyword.fetch(opts, :offset),
         {:ok, limit} <- Keyword.fetch(opts, :limit) do
      request
      |> Req.Request.put_new_header("X-Plex-Container-Start", to_string(offset))
      |> Req.Request.put_new_header("X-Plex-Container-Size", to_string(limit))
    else
      _ -> request
    end
  end
end

defmodule PlexExporter.Plex.Library do
  @moduledoc """
  Get information about the library, including media
  """

  alias PlexExporter.Plex.Client

  @doc """
  Get a list of library sections
  """
  @spec sections(Client.opts()) :: Client.response()
  def sections(opts \\ []) do
    Client.get("/library/sections", opts)
  end

  @doc """
  Get information about a library section
  """
  @spec section(String.t(), Client.opts()) :: Client.response()
  def section(section_id, opts \\ []) do
    Client.get("/library/sections/#{section_id}/all", opts)
  end
end

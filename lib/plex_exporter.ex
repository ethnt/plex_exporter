defmodule PlexExporter do
  @doc """
  Create a `Config` struct from the runtime configuration
  """
  @spec config :: PlexExporter.Config.t()
  def config do
    %PlexExporter.Config{
      url: Application.fetch_env!(:plex_exporter, :plex_url),
      token: Application.fetch_env!(:plex_exporter, :plex_token)
    }
  end
end

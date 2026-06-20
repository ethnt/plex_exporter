defmodule PlexExporter.Config do
  @doc """
  Gets the port from `PORT`, defauling to 9000
  """
  def port do
    Application.get_env(:plex_exporter, :port, 9000)
  end

  @doc """
  Gets the Plex url from `PLEX_URL`
  """
  @spec plex_url :: String.t()
  def plex_url do
    Application.get_env(:plex_exporter, :plex_url) ||
      raise "Must set PLEX_URL"
  end

  @doc """
  Gets the Plex token. Prefers `PLEX_TOKEN_FILE` over `PLEX_TOKEN`, will raise
  if neither are present or reading `PLEX_TOKEN_FILE` fails
  """
  @spec plex_token :: String.t()
  def plex_token do
    case Application.get_env(:plex_exporter, :plex_token_file) do
      token_file when is_binary(token_file) ->
        case File.read(token_file) do
          {:ok, contents} ->
            String.trim(contents)

          {:error, reason} ->
            raise "Cannot read PLEX_TOKEN_FILE (#{token_file}): #{:file.format_error(reason)}"
        end

      _ ->
        Application.get_env(:plex_exporter, :plex_token) ||
          raise "Must set PLEX_TOKEN_FILE or PLEX_TOKEN"
    end
  end
end

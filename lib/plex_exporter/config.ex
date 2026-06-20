defmodule PlexExporter.Config do
  @moduledoc """
  Fetch configuration values
  """

  require Logger

  @doc """
  Validates that all necessary configuration is present, exiting if not
  """
  @spec validate! :: :ok
  def validate! do
    plex_url()
    plex_token()

    :ok
  end

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
    Application.get_env(:plex_exporter, :plex_url) || exit!("Must set PLEX_URL")
  end

  @doc """
  Gets the Plex token. Prefers `PLEX_TOKEN_FILE` over `PLEX_TOKEN`, will exit
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
            exit!("Cannot read PLEX_TOKEN_FILE (#{token_file}): #{:file.format_error(reason)}")
        end

      _ ->
        Application.get_env(:plex_exporter, :plex_token) ||
          exit!("Must set PLEX_TOKEN_FILE or PLEX_TOKEN")
    end
  end

  @spec exit!(String.t()) :: no_return()
  defp exit!(message) do
    Logger.error(message)
    System.stop(1)
    Process.sleep(:infinity)
  end
end

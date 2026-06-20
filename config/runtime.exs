import Config

if config_env() != :test do
  config :logger, :default_handler, formatter: LoggerJSON.Formatters.Basic.new()

  config :plex_exporter,
    plex_url: System.get_env("PLEX_URL"),
    plex_token: System.get_env("PLEX_TOKEN"),
    plex_token_file: System.get_env("PLEX_TOKEN_FILE"),
    port: System.get_env("PORT", "9000")
end

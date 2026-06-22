import Config

if config_env() != :test do
  log_level = "LOG_LEVEL" |> System.get_env("info") |> String.to_existing_atom()

  formatter =
    case System.get_env("LOG_FORMAT", "console") do
      "json" -> LoggerJSON.Formatters.Basic.new()
      _ -> Logger.Formatter.new()
    end

  config :logger, :default_handler, formatter: formatter
  config :logger, level: log_level

  config :plex_exporter,
    plex_url: System.get_env("PLEX_URL"),
    plex_token: System.get_env("PLEX_TOKEN"),
    plex_token_file: System.get_env("PLEX_TOKEN_FILE"),
    port: System.get_env("PORT", "9000"),
    metrics_refresh_interval: System.get_env("METRICS_REFRESH_INTERVAL", "900")
end

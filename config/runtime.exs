import Config

if config_env() != :test do
  config :plex_exporter,
    plex_url: System.fetch_env!("PLEX_URL"),
    plex_token: System.fetch_env!("PLEX_TOKEN")
end

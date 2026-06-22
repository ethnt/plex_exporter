# plex_exporter

A Prometheus exporter for your Plex server, including metrics about active sessions and your library.

## Running

### Docker

```yaml
services:
  plex_exporter:
    image: ghcr.io/ethnt/plex_exporter:latest
    restart: unless-stopped
    ports:
      - "9000:9000"
    environment:
      PLEX_URL: http://plex:32400
      PLEX_TOKEN: your-token-here # or...
      PLEX_TOKEN_FILE: /var/lib/plex_exporter/token
      # PORT: 9000
    volumes:
      - /var/lib/plex_exporter/token
```

### Nix

You can add this project as a Flake input:

```nix
{
  inputs = {
    plex-exporter.url = "github:ethnt/plex_exporter";
  };
}
```

Add the overlay containing the package:

```nix
{
  nixpkgs.overlays = [
    plex-exporter.overlays.default
  ];
}
```

And then include and use the NixOS module:

```nix
{
  nixpkgs.lib.nixosSystem {
    modules = [
      plex-exporter.nixosModules.default
      ({
        services.plex-exporter = {
          enable = true;
          url = "http://plex:32400";
          tokenFile = /run/secrets/plex_token;
        };
      })
    ];
  };
}
```

## Configuration

### Environment variables

| Variable                          | Default   | Description                                                                                                                                     |
| --------------------------------- | --------- | ----------------------------------------------------------------------------------------------------------------------------------------------- |
| `PLEX_URL`                        |           | The Plex server URL                                                                                                                             |
| `PLEX_TOKEN_FILE` or `PLEX_TOKEN` |           | File containing your [Plex token](https://support.plex.tv/articles/204059436-finding-an-authentication-token-x-plex-token/) or the token itself |
| `PORT`                            | `9000`    | Port that the exporter will run on                                                                                                              |
| `METRICS_REFRESH_INTERVAL`        | `900`     | How frequently to refetch cached metrics, in seconds                                                                                            |
| `LOG_LEVEL`                       | `info`    | Log level (`debug`, `info`, `warning`, `error`)                                                                                                 |
| `LOG_FORMAT`                      | `console` | Log format (`console`, `json`)                                                                                                                  |

## Metrics

```
# TYPE plex_server_status gauge
# HELP plex_server_status Plex server status
plex_server_status{name="Your Plex Server"} 1
# TYPE plex_library_items gauge
# HELP plex_library_items Number of Plex library items
plex_library_items{title="TV Shows",type="show"} 467
plex_library_items{title="TV Shows - Episodes",type="show_episode"} 13831
plex_library_items{title="Movies",type="movie"} 1018
plex_library_items{title="Other Videos",type="movie"} 2
# TYPE plex_active_sessions gauge
# HELP plex_active_sessions Number of active Plex sessions
plex_active_sessions{type="transcode"} 0
plex_active_sessions{type="direct_play"} 1
plex_active_sessions{type="direct_stream"} 0
```

## License

`plex_exporter` is available under the MIT License.

# plex_exporter

A Prometheus exporter for your Plex server, including metrics about active sessions and your library.

## Running

### Docker

```yaml
services:
  prometheus-plex-exporter:
    image: ghcr.io/ethnt/prometheus-plex-exporter:latest
    restart: unless-stopped
    ports:
      - "9000:9000"
    environment:
      PLEX_URL: http://plex:32400
      PLEX_TOKEN: your-token-here # or...
      PLEX_TOKEN_FILE: /var/lib/plex_exporter/token
    volumes:
      - /var/lib/plex_exporter/token
      # PORT: 9000
```

### Nix

#### With `flake-parts`

Import `flakeModules.default` — it exposes `packages.prometheus-plex-exporter`, `overlays.default`, and a `nixosModules.default` that bundles the overlay automatically:

```nix
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    prometheus-plex-exporter.url = "github:ethnt/prometheus-plex-exporter";
  };

  outputs = inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [ inputs.prometheus-plex-exporter.flakeModules.default ];

      systems =
        [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];

      flake.nixosConfigurations.my-machine = inputs.nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          inputs.prometheus-plex-exporter.nixosModules.default
          {
            services.prometheus-plex-exporter = {
              enable = true;
              url = "http://plex:32400";
              tokenFile = /run/secrets/plex_token;
            };
          }
        ];
      };
    };
}
```

#### Without `flake-parts`

Add the overlay so `pkgs.prometheus-plex-exporter` resolves, then import the NixOS module:

```nix
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    prometheus-plex-exporter.url = "github:ethnt/prometheus-plex-exporter";
  };

  outputs = { nixpkgs, prometheus-plex-exporter, ... }: {
    nixosConfigurations.my-machine = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        { nixpkgs.overlays = [ prometheus-plex-exporter.overlays.default ]; }
        prometheus-plex-exporter.nixosModules.default
        {
          services.prometheus-plex-exporter = {
            enable = true;
            url = "http://plex:32400";
            tokenFile = /run/secrets/plex_token;
          };
        }
      ];
    };
  };
}
```

## Configuration

### Environment variables

| Variable                          | Default | Description                                                                                                                                     |
| --------------------------------- | ------- | ----------------------------------------------------------------------------------------------------------------------------------------------- |
| `PLEX_URL`                        |         | The Plex server URL                                                                                                                             |
| `PLEX_TOKEN_FILE` or `PLEX_TOKEN` |         | File containing your [Plex token](https://support.plex.tv/articles/204059436-finding-an-authentication-token-x-plex-token/) or the token itself |
| `PORT`                            | `9000`  | Port that the exporter will run on                                                                                                              |

## Metrics

```
# TYPE plex_library_items gauge
# HELP plex_library_items Number of Plex library items
plex_library_items{title="TV Shows",type="show"} 467
plex_library_items{title="TV Shows - Episodes",type="show_episode"} 13831
plex_library_items{title="Movies",type="movie"} 1018
plex_library_items{title="Other Videos",type="movie"} 2
# TYPE plex_total_sessions gauge
# HELP plex_total_sessions Number of active Plex sessions
plex_total_sessions{type="transcode"} 0
plex_total_sessions{type="direct_play"} 1
plex_total_sessions{type="direct_stream"} 0
```

## Licensing

`plex_exporter` is available under the MIT License.

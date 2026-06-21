{ config, lib, pkgs, ... }:

with lib;

let cfg = config.services.plex-exporter;
in {
  options.services.plex-exporter = {
    enable = mkEnableOption "plex-exporter";

    package = mkOption {
      type = types.package;
      description = "Package to use for `plex-exporter`";
      default = pkgs.plex_exporter;
    };

    url = mkOption {
      type = types.str;
      description = "The URL of your Plex server";
      example = "https://plex:32400";
    };

    tokenFile = mkOption {
      type = types.path;
      description = "Path to a file containing your Plex token";
      example = /run/secrets/plex_token;
    };

    port = mkOption {
      type = types.port;
      description = "The port your exporter will run on";
      default = 9000;
    };

    openFirewall = mkOption {
      type = types.bool;
      description = "If the firewall should allow requests to the exporter";
      default = false;
    };
  };

  config = mkIf cfg.enable {
    systemd.services.plex-exporter = {
      description = "plex-exporter";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];

      environment = {
        PLEX_URL = cfg.url;
        PLEX_TOKEN_FILE = cfg.tokenFile;
        PORT = toString cfg.port;
      };

      serviceConfig = {
        Type = "simple";
        DynamicUser = true;
        ExecStart = "${lib.getExe cfg.package} start";
        Restart = "on-failure";
        RestartSec = 5;
      };
    };

    networking.firewall =
      mkIf cfg.openFirewall { allowedTCPPorts = [ cfg.port ]; };
  };
}

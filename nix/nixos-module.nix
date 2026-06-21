{ config, lib, pkgs, ... }:

with lib;

let cfg = config.services.prometheus-plex-exporter;
in {
  options.services.prometheus-plex-exporter = {
    enable = mkEnableOption "prometheus-plex-exporter";

    package = mkPackageOption pkgs "prometheus-plex-exporter";

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
    systemd.services.prometheus-plex-exporter = {
      description = "plex_exporter";
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
  };
}

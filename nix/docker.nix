{ dockerTools, prometheus-plex-exporter, lib, bash, cacert, openssl, }:

dockerTools.buildLayeredImage {
  name = "prometheus-plex-exporter";

  contents =
    [ dockerTools.fakeNss bash cacert openssl prometheus-plex-exporter ];

  config = {
    Cmd = [ (lib.getExe prometheus-plex-exporter) "start" ];
    Env = [ "LANG=C.UTF-8" "LC_ALL=C.UTF-8" ];
    ExposedPorts."9000/tcp" = { };
    User = "1000:1000";
  };
}

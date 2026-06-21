{ dockerTools, plex_exporter, lib, bash, cacert, openssl, ncurses }:

dockerTools.buildLayeredImage {
  name = "plex-exporter";

  contents = [ dockerTools.fakeNss bash cacert openssl ncurses plex_exporter ];

  config = {
    Cmd = [ (lib.getExe plex_exporter) "start" ];
    Env = [ "LANG=C.UTF-8" "LC_ALL=C.UTF-8" ];
    ExposedPorts."9000/tcp" = { };
    User = "1000:1000";
  };
}

{ beam27Packages, elixir_1_18 }:

let
  beamPackages = beam27Packages.extend (self: super: { elixir = elixir_1_18; });
in beamPackages.mixRelease rec {
  pname = "prometheus-plex-exporter";
  version = "dev";
  src = ../.;
  mixEnv = "prod";

  mixFodDeps = beamPackages.fetchMixDeps {
    inherit pname version src mixEnv;
    hash = "sha256-V2etU6jwmybTH7IUdusqvW+XXnYBVJ5ZTLRCOhpcS+A=";
  };

  removeCookie = false;

  meta.mainProgram = "plex_exporter";
}

{ beam27Packages }:
let
  beamPackages = beam27Packages.extend
    (self: super: { elixir = beam27Packages.elixir_1_19; });
in
beamPackages.mixRelease rec {
  pname = "plex-exporter";
  version = "0.0.4";
  src = ../../.;
  mixEnv = "prod";

  mixFodDeps = beamPackages.fetchMixDeps {
    inherit pname version src mixEnv;
    hash = "sha256-KH+hRtEO4QF43aCldhAzY6bnLQBqOf+v+Ej0BJBTpj8=";
  };

  removeCookie = false;

  meta.mainProgram = "plex_exporter";
}

{ beam27Packages, elixir_1_18 }:
let
  beamPackages = beam27Packages.extend (self: super: { elixir = elixir_1_18; });
in beamPackages.mixRelease rec {
  pname = "plex-exporter";
  version = "0.0.2";
  src = ../../.;
  mixEnv = "prod";

  mixFodDeps = beamPackages.fetchMixDeps {
    inherit pname version src mixEnv;
    hash = "sha256-KH+hRtEO4QF43aCldhAzY6bnLQBqOf+v+Ej0BJBTpj8=";
  };

  removeCookie = false;

  meta.mainProgram = "plex_exporter";
}

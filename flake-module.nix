{ self }: {
  flake.nixosModules.default = { ... }: {
    imports = [ ./nix/nixos-module.nix ];
    nixpkgs.overlays = [ self.overlays.default ];
  };

  flake.overlays.default = final: _prev: {
    prometheus-plex-exporter =
      self.packages.${final.stdenv.hostPlatform.system}.default;
  };

  perSystem = { system, ... }: {
    packages.prometheus-plex-exporter = self.packages.${system}.default;
  };
}

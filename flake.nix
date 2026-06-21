{
  description = "plex_exporter";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    flake-parts.url = "github:hercules-ci/flake-parts";

    treefmt.url = "github:numtide/treefmt-nix";
    treefmt.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ nixpkgs, flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } ({ self, ... }: {
      systems = nixpkgs.lib.systems.flakeExposed;

      imports = with inputs; [ treefmt.flakeModule ];

      flake = {
        overlays.default = final: _prev: {
          plex-exporter =
            self.packages.${final.stdenv.hostPlatform.system}.default;
        };

        nixosModules.plex-exporter = { ... }: {
          imports = [ ./nix/nixos-module.nix ];
        };
      };

      perSystem = { config, lib, pkgs, self', ... }: {
        packages = {
          default = pkgs.callPackage ./nix/packages/default.nix { };
        } // lib.optionalAttrs pkgs.stdenv.isLinux {
          docker = pkgs.callPackage ./nix/packages/docker.nix {
            plex_exporter = self'.packages.default;
          };
        };

        devShells.default = pkgs.mkShell {
          packages = with pkgs;
            [ docker elixir_1_19 just ] ++ [ config.treefmt.build.wrapper ]
            ++ (builtins.attrValues config.treefmt.build.programs);

          shellHook = ''
            export LANG="en_US.UTF-8"
            export ERL_AFLAGS="-kernel shell_history enabled"
            export ELIXIR_ERL_OPTIONS="-kernel shell_history enabled"
            export MIX_ENV="''${MIX_ENV:-dev}"

            export MIX_HOME="$PWD/.elixir/mix"
            export HEX_HOME="$PWD/.elixir/hex"

            export PATH="$MIX_HOME/bin:$PATH"
            export PATH="$HEX_HOME/bin:$PATH"
          '';
        };

        treefmt.config = {
          projectRootFile = "flake.nix";
          programs = {
            nixfmt = {
              enable = true;
              package = pkgs.nixfmt-classic;
            };
            prettier.enable = true;
          };
          settings.formatter = {
            elixir = {
              command = lib.getExe' pkgs.elixir_1_19 "mix";
              options = [ "format" ];
              includes = [ "*.ex" "*.exs" "*.heex" ];
            };
          };
        };
      };
    });
}

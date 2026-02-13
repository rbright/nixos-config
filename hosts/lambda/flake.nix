{
  description = "Configuration for managed hosts";

  inputs = {
    darwin = {
      url = "github:LnL7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    homebrew-cask = {
      flake = false;
      url = "github:homebrew/homebrew-cask";
    };
    homebrew-core = {
      flake = false;
      url = "github:homebrew/homebrew-core";
    };
    homebrew-steipete-tap = {
      flake = false;
      url = "github:steipete/homebrew-tap";
    };
    macosModules = {
      flake = false;
      url = "path:../../modules/macos";
    };
    nix-homebrew.url = "github:zhaofengli/nix-homebrew";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    sharedModules = {
      flake = false;
      url = "path:../../modules/shared";
    };
  };

  outputs =
    {
      darwin,
      home-manager,
      homebrew-cask,
      homebrew-core,
      homebrew-steipete-tap,
      macosModules,
      nix-homebrew,
      nixpkgs,
      sharedModules,
      ...
    }:
    let
      system = "aarch64-darwin";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      darwinConfigurations.lambda = darwin.lib.darwinSystem {
        inherit system;
        specialArgs = {
          hostName = "lambda";
          user = "rbright";
        };
        modules = [
          home-manager.darwinModules.home-manager
          nix-homebrew.darwinModules.nix-homebrew
          {
            nix-homebrew = {
              autoMigrate = true;
              enable = true;
              enableRosetta = true;
              mutableTaps = false;
              taps = {
                "homebrew/homebrew-cask" = homebrew-cask;
                "homebrew/homebrew-core" = homebrew-core;
                "steipete/homebrew-tap" = homebrew-steipete-tap;
              };
              user = "rbright";
            };
          }
          sharedModules.outPath
          macosModules.outPath
          ./default.nix
        ];
      };

      devShells.${system}.default = pkgs.mkShell {
        nativeBuildInputs = with pkgs; [
          bashInteractive
          deadnix
          git
          nixd
          nixfmt
          ripgrep
          statix
        ];
        shellHook = ''
          export EDITOR=nvim
        '';
      };

      formatter.${system} = pkgs.nixfmt;
    };
}

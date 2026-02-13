{
  description = "Configuration for lambda (macOS) and omega (Ubuntu)";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    darwin = {
      url = "github:LnL7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Lambda-only inputs.
    nix-homebrew.url = "github:zhaofengli/nix-homebrew";
    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };
    homebrew-steipete-tap = {
      url = "github:steipete/homebrew-tap";
      flake = false;
    };
  };

  outputs =
    {
      nixpkgs,
      darwin,
      home-manager,
      nix-homebrew,
      homebrew-core,
      homebrew-cask,
      homebrew-steipete-tap,
      ...
    }@inputs:
    let
      user = "rbright";
      systems = {
        lambda = "aarch64-darwin";
        omega = "x86_64-linux";
      };
      supportedSystems = builtins.attrValues systems;
      forAllSystems = f: nixpkgs.lib.genAttrs supportedSystems f;
      devShell =
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          default =
            with pkgs;
            mkShell {
              nativeBuildInputs = with pkgs; [
                bashInteractive
                deadnix
                git
                nixd
                nixfmt-rfc-style
                statix
              ];
              shellHook = ''
                export EDITOR=nvim
              '';
            };
        };
    in
    {
      devShells = forAllSystems devShell;
      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.nixfmt);

      darwinConfigurations.lambda = darwin.lib.darwinSystem {
        system = systems.lambda;
        specialArgs = inputs // {
          inherit user;
          hostName = "lambda";
        };
        modules = [
          home-manager.darwinModules.home-manager
          nix-homebrew.darwinModules.nix-homebrew
          {
            nix-homebrew = {
              inherit user;

              enable = true;
              autoMigrate = true;
              enableRosetta = true;
              mutableTaps = false;

              taps = {
                "homebrew/homebrew-core" = homebrew-core;
                "homebrew/homebrew-cask" = homebrew-cask;
                # `brew tap steipete/tap` maps to the `steipete/homebrew-tap` repo.
                "steipete/homebrew-tap" = homebrew-steipete-tap;
              };
            };
          }
          ./hosts/lambda
        ];
      };

      homeConfigurations.omega = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.${systems.omega};
        extraSpecialArgs = inputs // {
          inherit user;
        };
        modules = [
          ./hosts/omega
        ];
      };
    };
}

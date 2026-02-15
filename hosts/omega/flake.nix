{
  description = "Configuration for managed hosts";

  inputs = {
    codexCliNix = {
      url = "github:sadjow/codex-cli-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    vicinaeExtensions = {
      url = "github:vicinaehq/extensions";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixosModules = {
      flake = false;
      url = "path:../../modules/nixos";
    };
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    sharedModules = {
      flake = false;
      url = "path:../../modules/shared";
    };
  };

  outputs =
    {
      codexCliNix,
      home-manager,
      vicinaeExtensions,
      nixosModules,
      nixpkgs,
      sharedModules,
      ...
    }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      nixosConfigurations.omega = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {
          hostName = "omega";
          user = "rbright";
          inherit vicinaeExtensions;
        };
        modules = [
          home-manager.nixosModules.home-manager
          {
            nixpkgs.overlays = [
              codexCliNix.overlays.default
            ];
          }
          sharedModules.outPath
          nixosModules.outPath
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

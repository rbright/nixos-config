{
  description = "Configuration for managed hosts";

  inputs = {
    home-manager = {
      url = "github:nix-community/home-manager";
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
      home-manager,
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
        };
        modules = [
          home-manager.nixosModules.home-manager
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

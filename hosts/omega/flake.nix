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
    koko = {
      url = "path:/home/rbright/Projects/koko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixPiAgent = {
      url = "path:/home/rbright/Projects/nix-packages/nix-pi-agent";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    riva = {
      url = "path:/home/rbright/Projects/riva";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sotto = {
      url = "path:/home/rbright/Projects/sotto";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    vicinaeExtensions = {
      url = "github:vicinaehq/extensions";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    waybarAgentUsage = {
      url = "path:/home/rbright/Projects/waybar-modules/waybar-agent-usage";
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
      koko,
      nixPiAgent,
      riva,
      sotto,
      vicinaeExtensions,
      waybarAgentUsage,
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
          inherit
            nixPiAgent
            vicinaeExtensions
            waybarAgentUsage
            ;
        };
        modules = [
          home-manager.nixosModules.home-manager
          {
            nixpkgs.overlays = [
              codexCliNix.overlays.default
            ];
            environment.systemPackages = [
              koko.packages.${pkgs.stdenv.hostPlatform.system}.koko
            ];
          }
          sharedModules.outPath
          nixosModules.outPath
          riva.nixosModules.default
          sotto.nixosModules.default
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

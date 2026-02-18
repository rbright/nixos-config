{
  description = "Standalone Nix package for pi-coding-agent from badlogic/pi-mono";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs =
    { self, nixpkgs }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      forAllSystems = f: nixpkgs.lib.genAttrs systems f;
    in
    {
      packages = forAllSystems (
        system:
        let
          pkgs = import nixpkgs { inherit system; };
          piCodingAgent = pkgs.callPackage ./package.nix { };
        in
        {
          pi-coding-agent = piCodingAgent;
          default = piCodingAgent;
        }
      );

      apps = forAllSystems (
        system:
        let
          piCodingAgent = self.packages.${system}.pi-coding-agent;
        in
        {
          pi-coding-agent = {
            type = "app";
            program = "${piCodingAgent}/bin/pi";
            meta = {
              description = "Run pi-coding-agent";
            };
          };
          default = {
            type = "app";
            program = "${piCodingAgent}/bin/pi";
            meta = {
              description = "Run pi-coding-agent";
            };
          };
        }
      );

      devShells = forAllSystems (
        system:
        let
          pkgs = import nixpkgs { inherit system; };
        in
        {
          default = pkgs.mkShell {
            packages = with pkgs; [
              bash
              curl
              jq
              nix
              nodejs_22
              perl
              prefetch-npm-deps
              gnutar
              shellcheck
              nixfmt
            ];
          };
        }
      );
    };
}

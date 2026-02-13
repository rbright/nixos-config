{ lib, pkgs, ... }:
let
  # Resolve font attributes safely so shared config can be reused across systems.
  fontPaths = [
    [ "fira-code" ]
    [ "fira-code-symbols" ]
    [ "ibm-plex" ]
    [ "inter" ]
    [ "lato" ]
    [ "lexend" ]
    [ "montserrat" ]
    [
      "nerd-fonts"
      "fira-code"
    ]
    [
      "nerd-fonts"
      "geist-mono"
    ]
    [
      "nerd-fonts"
      "hack"
    ]
    [
      "nerd-fonts"
      "jetbrains-mono"
    ]
    [ "quicksand" ]
  ];
in
{
  fonts.packages = builtins.filter (package: package != null) (
    builtins.map (path: lib.attrByPath path null pkgs) fontPaths
  );
}

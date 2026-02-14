{ pkgs, ... }:
let
  mkBraveProfileLauncher =
    {
      name,
      userDataDir,
    }:
    pkgs.writeShellScriptBin name ''
      set -eu

      profile_path="''${XDG_CONFIG_HOME:-$HOME/.config}/BraveSoftware/${userDataDir}"
      mkdir -p "$profile_path"

      exec ${pkgs.brave}/bin/brave --user-data-dir="$profile_path" "$@"
    '';

  bravePersonal = mkBraveProfileLauncher {
    name = "brave-personal";
    userDataDir = "Brave-Browser";
  };

  braveWork = mkBraveProfileLauncher {
    name = "brave-work";
    userDataDir = "Brave-Browser-Work";
  };
in
{
  home.packages = [
    bravePersonal
    braveWork
  ];

  xdg.desktopEntries = {
    "brave-personal" = {
      name = "Brave Personal";
      genericName = "Web Browser";
      exec = "brave-personal %U";
      icon = "brave-browser";
      terminal = false;
      categories = [
        "Network"
        "WebBrowser"
      ];
      mimeType = [
        "x-scheme-handler/http"
        "x-scheme-handler/https"
        "text/html"
      ];
    };

    "brave-work" = {
      name = "Brave Work";
      genericName = "Web Browser";
      exec = "brave-work %U";
      icon = "brave-browser";
      terminal = false;
      categories = [
        "Network"
        "WebBrowser"
      ];
      mimeType = [
        "x-scheme-handler/http"
        "x-scheme-handler/https"
        "text/html"
      ];
    };
  };
}

{
  config,
  lib,
  pkgs,
  ...
}:
let
  thunderbirdThemeRoot = ./thunderbird;
in
{
  xdg.configFile."thunderbird/chrome/userChrome.css".source =
    thunderbirdThemeRoot + "/userChrome.css";
  xdg.configFile."thunderbird/chrome/userContent.css".source =
    thunderbirdThemeRoot + "/userContent.css";

  # Keep Thunderbird chrome/content CSS linked into whichever profile is marked
  # Default=1 in ~/.thunderbird/profiles.ini.
  home.activation.linkThunderbirdTheme = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    profile_ini="${config.home.homeDirectory}/.thunderbird/profiles.ini"

    if [ -f "$profile_ini" ]; then
      default_profile_info="$(${pkgs.gawk}/bin/awk -F= '
        /^\[Profile[0-9]+\]$/ {
          if (inProfile && isDefault && path != "") {
            found = 1
            print path "|" isRelative;
            exit
          }
          inProfile = 1
          path = ""
          isDefault = 0
          isRelative = 1
          next
        }

        /^\[/ {
          if (inProfile && isDefault && path != "") {
            found = 1
            print path "|" isRelative;
            exit
          }
          inProfile = 0
          next
        }

        inProfile && $1 == "Path" { path = $2; next }
        inProfile && $1 == "Default" { isDefault = ($2 == "1"); next }
        inProfile && $1 == "IsRelative" { isRelative = $2; next }

        END {
          if (!found && inProfile && isDefault && path != "") {
            print path "|" isRelative
          }
        }
      ' "$profile_ini")"

      if [ -n "$default_profile_info" ]; then
        profile_path="''${default_profile_info%|*}"
        is_relative="''${default_profile_info#*|}"

        if [ "$is_relative" = "0" ]; then
          profile_dir="$profile_path"
        else
          profile_dir="${config.home.homeDirectory}/.thunderbird/$profile_path"
        fi

        chrome_dir="$profile_dir/chrome"

        $DRY_RUN_CMD mkdir -p "$chrome_dir"
        $DRY_RUN_CMD ln -sfn "${config.xdg.configHome}/thunderbird/chrome/userChrome.css" "$chrome_dir/userChrome.css"
        $DRY_RUN_CMD ln -sfn "${config.xdg.configHome}/thunderbird/chrome/userContent.css" "$chrome_dir/userContent.css"
      else
        echo "thunderbird theme: no default profile in $profile_ini; skipping chrome symlink"
      fi
    else
      echo "thunderbird theme: $profile_ini not found; skipping chrome symlink"
    fi
  '';
}

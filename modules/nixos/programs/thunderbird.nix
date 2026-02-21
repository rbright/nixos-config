_: {
  programs.thunderbird = {
    enable = true;

    # Treat Nix as source of truth for these prefs across hosts/profiles.
    preferencesStatus = "locked";

    preferences = {
      # Required for custom userChrome.css / userContent.css styling.
      "toolkit.legacyUserProfileCustomizations.stylesheets" = true;

      # UI density and dark-mode defaults.
      "mail.uidensity" = 1;
      "mail.tabs.drawInTitlebar" = true;
      "ui.systemUsesDarkTheme" = 1;

      # Align Thunderbird typography with the rest of the desktop.
      "font.default.x-western" = "sans-serif";
      "font.name.sans-serif.x-western" = "IBM Plex Sans";
      "font.name-list.sans-serif.x-western" = "IBM Plex Sans,Inter,sans-serif";
      "font.name.sans-serif.x-unicode" = "IBM Plex Sans";
      "font.name-list.sans-serif.x-unicode" = "IBM Plex Sans,Inter,sans-serif";
      "font.name.monospace.x-western" = "IBM Plex Mono";
      "font.name-list.monospace.x-western" = "IBM Plex Mono,monospace";
      "font.minimum-size.x-western" = 11;
      "font.size.variable.x-western" = 15;
      "font.size.fixed.x-western" = 13;
    };
  };
}

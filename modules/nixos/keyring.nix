_: {
  # Provides org.freedesktop.secrets so apps can persist auth tokens.
  services.gnome.gnome-keyring.enable = true;

  # Keep keyring unlock explicit for both console and greetd-based GUI logins.
  security.pam.services = {
    login.enableGnomeKeyring = true;
    greetd.enableGnomeKeyring = true;
  };
}

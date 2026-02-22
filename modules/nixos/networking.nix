_: {
  networking = {
    networkmanager.enable = true;

    # Use Cloudflare DNS on NixOS hosts.
    nameservers = [
      "1.1.1.1"
      "1.0.0.1"
      "2606:4700:4700::1111"
      "2606:4700:4700::1001"
    ];
  };

  programs.nm-applet.enable = true;
}

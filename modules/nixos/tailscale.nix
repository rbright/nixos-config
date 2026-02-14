_: {
  services.tailscale = {
    # Install and run tailscaled for private tailnet connectivity.
    enable = true;

    # Allow direct peer traffic on the default Tailscale UDP port.
    openFirewall = true;

    # Keep Tailscale SSH enabled without managing per-host SSH keys.
    extraSetFlags = [ "--ssh=true" ];
  };
}

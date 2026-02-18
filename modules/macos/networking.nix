_: {
  ##############################################################################
  # General
  ##############################################################################

  networking = {
    # Set friendly name for the system
    computerName = "Ryan's MacBook Pro";

    # Set system hostname
    hostName = "lambda";

    # Set network services to configure
    knownNetworkServices = [
      "USB 10/100/1000 LAN"
      "Wi-Fi"
      "Thunderbolt Bridge"
    ];

    # Enable Wake-on-LAN
    wakeOnLan = {
      enable = true;
    };

    ##############################################################################
    # Firewall
    ##############################################################################

    applicationFirewall = {
      # Enable internal firewall
      enable = true;

      # SSH over Tailscale requires inbound firewall allowance
      blockAllIncoming = false;

      # Allow signed apps to accept incoming requests
      allowSigned = true;

      # Don't automatically allow signed apps to accept incoming requests
      allowSignedApp = false;

      # Enable stealth mode for the firewall
      enableStealthMode = true;
    };
  };
}

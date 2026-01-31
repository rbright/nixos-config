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

    # Set DNS servers
    dns = [
      "1.1.1.1"
      "1.0.0.1"
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

      # Block incoming requests
      blockAllIncoming = true;

      # Don't automatically allow signed apps to accept incoming requests
      allowSigned = false;

      # Don't automatically allow signed apps to accept incoming requests
      allowSignedApp = false;

      # Enable stealth mode for the firewall
      enableStealthMode = true;
    };
  };
}

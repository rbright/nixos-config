_:

{
  ##############################################################################
  # General
  ##############################################################################

  # Set friendly name for the system
  networking.computerName = "Ryan's MacBook Pro";

  # Set system hostname
  networking.hostName = "lambda";

  # Set network services to configure
  networking.knownNetworkServices = [
    "USB 10/100/1000 LAN"
    "Wi-Fi"
    "Thunderbolt Bridge"
  ];

  # Set DNS servers
  networking.dns = [
    "1.1.1.1"
    "1.0.0.1"
  ];

  # Enable Wake-on-LAN
  networking.wakeOnLan = {
    enable = true;
  };

  ##############################################################################
  # Firewall
  ##############################################################################

  # Enable internal firewall
  networking.applicationFirewall.enable = true;

  # Block incoming requests
  networking.applicationFirewall.blockAllIncoming = true;

  # Don't automatically allow signed apps to accept incoming requests
  networking.applicationFirewall.allowSigned = false;

  # Don't automatically allow signed apps to accept incoming requests
  networking.applicationFirewall.allowSignedApp = false;

  # Enable stealth mode for the firewall
  networking.applicationFirewall.enableStealthMode = true;
}

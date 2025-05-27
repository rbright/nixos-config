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

  # Don't automatically allow signed apps to accept incoming requests
  system.defaults.alf.allowsignedenabled = 0;

  # Don't automatically allow signed downloads to accept incoming requests
  system.defaults.alf.allowdownloadsignedenabled = 0;

  # Enable internal firewall
  system.defaults.alf.globalstate = 1;

  # Enable logging of requests made to the firewall
  system.defaults.alf.loggingenabled = 1;

  # Drop incoming ICMP requests
  system.defaults.alf.stealthenabled = 1;
}

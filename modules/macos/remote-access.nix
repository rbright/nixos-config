{ user, ... }:
{
  services.openssh = {
    enable = true;
    extraConfig = ''
      # Restrict logins to the Tailscale address space only.
      AllowUsers ${user}@100.64.0.0/10 ${user}@fd7a:115c:a1e0::/48
      AuthenticationMethods publickey
      ChallengeResponseAuthentication no
      ClientAliveCountMax 2
      ClientAliveInterval 120
      KbdInteractiveAuthentication no
      PasswordAuthentication no
      PermitRootLogin no
      PubkeyAuthentication yes
    '';
  };
}

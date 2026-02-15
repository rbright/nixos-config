{ user, ... }:
{
  security.sudo.extraRules = [
    {
      # Allow unattended config apply for the primary user without disabling
      # password prompts for unrelated privileged commands.
      users = [ user ];
      commands = [
        {
          command = "/run/current-system/sw/bin/nixos-rebuild";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];
}

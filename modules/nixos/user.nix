{ pkgs, user, ... }:
{
  # Enable shells at the system level for login-shell support.
  programs.zsh.enable = true;
  environment.shells = [ pkgs.nushell ];

  users.users.${user} = {
    description = "Ryan Bright";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    isNormalUser = true;
    shell = pkgs.nushell;
  };
}

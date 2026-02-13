{ pkgs, user, ... }:
{
  # Enable shells at the system level for login-shell support.
  programs.nushell.enable = true;
  programs.zsh.enable = true;

  users.users.${user} = {
    description = "Ryan Bright";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    isNormalUser = true;
    shell = pkgs.zsh;
  };
}

{ user, ... }:
{
  users.users.${user} = {
    description = "Ryan Bright";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    isNormalUser = true;
  };
}

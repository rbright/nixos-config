{ pkgs, user, ... }:
{
  users.users.${user} = {
    home = "/Users/${user}";
    isHidden = false;
    name = user;
    shell = pkgs.zsh;
  };
}

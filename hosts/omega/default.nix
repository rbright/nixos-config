{
  hostName ? "omega",
  ...
}:
{
  imports = [
    ./configuration.nix
  ];

  networking.hostName = hostName;
}

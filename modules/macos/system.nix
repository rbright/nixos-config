{ user, ... }:
{
  system = {
    checks.verifyNixPath = false;
    primaryUser = user;
    stateVersion = 5;
  };
}

_:

{
  nixpkgs = {
    config = {
      allowBroken = false;
      allowInsecure = false;
      allowUnfree = true;
      allowUnsupportedSystem = false;
    };
  };
}

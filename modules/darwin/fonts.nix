{
  pkgs,
  ...
}:

{
  fonts.packages = with pkgs; [
    fira-code
    fira-code-symbols
    inter
    lato
    montserrat
    nerd-fonts.fira-code
    nerd-fonts.hack
    quicksand
  ];
}

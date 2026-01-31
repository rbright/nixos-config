{pkgs, ...}: {
  fonts.packages = with pkgs; [
    fira-code
    fira-code-symbols
    ibm-plex
    inter
    lato
    lexend
    montserrat
    nerd-fonts.fira-code
    nerd-fonts.geist-mono
    nerd-fonts.hack
    nerd-fonts.jetbrains-mono
    quicksand
  ];
}

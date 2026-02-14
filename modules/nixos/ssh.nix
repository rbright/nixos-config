_: {
  # Route SSH operations through the 1Password agent socket.
  programs.ssh.extraConfig = ''
    Host *
      IdentityAgent ~/.1password/agent.sock
  '';
}

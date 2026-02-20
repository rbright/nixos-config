# NixOS Program Modules

## Purpose

This directory contains focused NixOS program modules imported by `modules/nixos/programs/default.nix`.

## Files

- `git.nix`: Git defaults, aliases, and SSH-signing config.
- `one-password.nix`: 1Password CLI/GUI enablement.
- `firefox.nix`: Firefox enablement.
- `thunar.nix`: Thunar + plugins + desktop service integration.
- `default.nix`: import list.

## Typical Changes

- Update Git aliasing/signing behavior: `git.nix`
- Adjust password manager integration: `one-password.nix`
- Tune file manager defaults/bookmarks: `thunar.nix`

## Workflow Notes

### 1Password SSH agent + Git signing

Relevant modules:

- `one-password.nix`
- `git.nix`
- `../ssh.nix`

Setup check:

```sh
printf '%s %s\n' "$(git config user.email)" "$(cat ~/.ssh/id_ed25519.pub)" > ~/.ssh/allowed_signers
chmod 600 ~/.ssh/allowed_signers
git config --global --get gpg.format
```

Expected: `gpg.format` is `ssh` and SSH signing can be used for commits.

## Verification

```sh
just lint
just build omega
just switch omega
```

Optional runtime checks:

```sh
git config --global --list
thunar --version
```

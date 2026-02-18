# Agent Guide

## Scope

These rules apply to the entire `nixos-config` repository.

## Mission

Ship safe, host-aware Nix changes that stay easy to review, verify, and roll back.

## Instruction Map (Progressive Disclosure)

- **Repo-wide rules:** this file (`AGENTS.md`)
- **Dotfiles runtime rules:** `modules/nixos/home-manager/dotfiles/AGENTS.md`
- **Local pi package maintenance:** `pkgs/pi-coding-agent/AGENTS.md`
- **User-facing workflows/commands:** `README.md` and `justfile`
- **Task execution artifacts:** `PLAN.md` and `SESSION.md`

## First 60 Seconds

1. Identify affected host(s): `lambda`, `omega`, or both.
2. Read the target files before editing.
3. Pick the minimal verification set from `just --list` based on changed scope.

## Workflow Rules

| Scope | Problem | Rule | Why | Example | When to use | Benefits |
| --- | --- | --- | --- | --- | --- | --- |
| Repo | Cross-host regressions and noisy lockfile churn | Keep host entrypoint/lock changes scoped to the host you are changing; put shared policy in `modules/`. | Prevents accidental drift between `lambda` and `omega`. | Edit `hosts/omega/*` + `modules/nixos/*` for Linux-only work. | Any host config change | Smaller diffs and safer rollbacks |
| Repo | CI and pre-commit failures | Run `just lint` before hand-off. | CI (`.github/workflows/lint.yml`) and local hooks enforce this gate. | `just lint` | Any repo change | Fewer failed reviews and reruns |
| Repo | Eval/build regressions not caught by lint | Run `just build <host>` for each affected host. | Confirms Nix evaluation and option wiring for the target system. | `just build omega` | Nix module, package, host, or dotfile wiring changes | Catch integration errors early |
| Repo | Runtime desktop regressions | If editing desktop dotfiles, follow the nearest scoped rules in `modules/nixos/home-manager/dotfiles/AGENTS.md`. | Runtime behavior is only partially covered by static checks. | Run `just hypr-smoke` for Hyprland-impacting changes. | Changes under `modules/nixos/home-manager/dotfiles/` | Higher confidence in interactive behavior |
| Repo | Docs drift after behavior changes | Update `README.md` when commands, defaults, or operational behavior change. | Recent fixes repeatedly required README sync to avoid stale runbooks. | Document a new shortcut or service workflow in `README.md`. | Any user-visible behavior/workflow change | Faster future maintenance |
| Repo | Lost decision context | Keep `PLAN.md` checklist + `SESSION.md` execution log current for multi-step work. | Preserves what was done, why, and how to reproduce verification. | Add executed commands and outcomes in `SESSION.md`. | Multi-step or non-trivial tasks | Better handoff and auditability |

## Validation Baseline

Minimum checks before hand-off:

1. `just lint`
2. `just build <affected-host>` (run once per affected host)
3. Additional scoped checks from the nearest subtree `AGENTS.md`

If a check is skipped, state exactly what was skipped, why, and the command to run.

## Git Hygiene

- Do not create/switch branches, commit, or push unless explicitly requested.
- Keep changes scoped; avoid unrelated refactors.

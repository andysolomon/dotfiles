---
name: tailscale-machine-ops
description: SSH and remote-development operating notes for Andrew Solomon's Tailscale-connected Macs. Use when Codex or Claude Code needs to SSH between Andrew's machines, identify the current host, start or attach tmux on SSH login, choose host-specific tmux colors, run T3 Code through the npxt3 command, or perform machine-to-machine setup using the known Tailscale device names and IPs.
---

# Tailscale Machine Ops

## Overview

Use this skill when operating across Andrew's Tailscale Macs. Prefer Tailscale hostnames over raw IPs when DNS works, but keep the IPs below as fallbacks.

## Machine Inventory

| Device | Local hostname aliases | Tailscale IP | OS | Tailscale status from screenshot | Role |
| --- | --- | --- | --- | --- | --- |
| `andrews-mac-mini-1` | `Andrews-Mac-mini`, `Andrews-Mac-mini.local` | `100.86.225.105` | macOS | Connected, Tailscale `1.94.1` | Current Mac mini / local UI machine |
| `qianas-macbook-pro-1` | `qianas-macbook-pro`, `qianas-macbook-pro.local` | `100.85.162.117` | macOS | Seen in Tailnet, Tailscale `1.94.2` | Other MacBook Pro / remote work machine |

The Tailscale account shown for both devices is `andrewsolomon.edu@gmail.com`. The expected local Unix user is `andrewsolomon` unless `whoami` on the target proves otherwise.

## SSH

Use these targets:

```sh
ssh andrewsolomon@andrews-mac-mini-1
ssh andrewsolomon@qianas-macbook-pro-1
ssh andrewsolomon@100.86.225.105
ssh andrewsolomon@100.85.162.117
```

Before changing another machine, confirm identity:

```sh
hostname
whoami
tailscale status --self
```

Do not push, merge, deploy, or run destructive commands on another machine unless the user explicitly asks.

## Tmux

SSH login should auto-attach to a tmux session named `ssh-$HOST`. Use `NO_AUTO_TMUX=1 ssh ...` when a raw shell is needed.

Expected host colors:

- `andrews-mac-mini-1` / `Andrews-Mac-mini`: green status accents.
- `qianas-macbook-pro-1` / `qianas-macbook-pro`: blue status accents.
- Unknown hosts: yellow status accents.

If tmux is not present on a host, install it with Homebrew before relying on SSH auto-attach:

```sh
brew install tmux
```

## T3 Code

Use `npxt3` to run the T3 Code npm package on either machine. It defaults to:

```sh
npx -y t3-code@latest
```

If the package name changes, set `T3_CODE_NPX_PACKAGE` before invoking:

```sh
T3_CODE_NPX_PACKAGE='actual-package@latest' npxt3
```

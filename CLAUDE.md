# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build and Deployment Commands

```bash
# Rebuild local system (run from this directory)
nixos-rebuild boot --flake . --sudo

# Test configuration without switching
nixos-rebuild test --flake . --sudo

# Remote deployment of makincc (uses Nushell)
nu deploycc.nu [mode]  # mode defaults to "switch"
```

## Architecture Overview

This is a flake-based NixOS configuration managing three hosts with shared, composable modules.

### Host Configurations

- **pc-nixos** (`hosts/pc-nixos/`) - Desktop with KDE, NVIDIA, gaming, full dev tools
- **makincc** (`hosts/makincc/`) - Server with Minecraft, PostgreSQL, S3/Garage, Tailscale (git submodule)
- **pc-wsl** (`hosts/pc-wsl/`) - WSL configuration

### Directory Structure

```
flake.nix           # Entry point - defines all hosts, inputs, and outputs
system/             # Shared system modules imported by hosts
├── de/             # Desktop environments (kde/, gnome/, cosmic/, hyprland/, homemade/)
├── dev/            # Dev tools: langs/ (rust, go, gleam, etc.) and programs/ (vscode, zed, claude-code)
├── programs/       # System applications (auto-collected via lib.collectNix)
├── shell/          # Shell config (Nushell is default)
├── hardware/       # Hardware modules (nvidia, razer, usb-wakeup-disable)
└── *.nix           # Feature modules (docker, gaming, wine, audio, etc.)
users/              # User configurations with home-manager
lib/                # Custom functions: withEnvPath, mkEnableDefaultOption, collectNix, mkConst
secrets/            # Encrypted secrets (agenix) - git submodule
keys.nix            # SSH public keys for users and hosts
```

### Configuration Patterns

**Module auto-collection**: Files in `system/programs/` are automatically imported via `lib.collectNix`. 
Add a new `.nix` file to git repo (must be staged).

**Secrets**: Managed with agenix. Encrypted `.age` files in `secrets/` submodule, decrypted at runtime via `config.age.secrets.<name>.path`.

### Key Dependencies

- `nixpkgs` (unstable) + `nixpkgs-stable` (25.05)
- `home-manager` for user environment
- `agenix` for secrets
- `impermanence` for ephemeral root filesystem support

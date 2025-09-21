#!/usr/bin/env nu

def main [mode = "switch"] {
    print $"Rebuilding in ($mode) mode."
    nixos-rebuild --target-host makinx-deploy $mode --flake ".#makincc" --sudo --ask-sudo-password
}

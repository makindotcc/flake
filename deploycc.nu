#!/usr/bin/env nu

nixos-rebuild --target-host makinx-deploy switch --flake ".#makincc" --sudo --ask-sudo-password

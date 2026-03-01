#!/usr/bin/env nu

def main [] {
    update_helium
    update_flake
}

def update_helium [] {
    let file = "system/programs/helium.nix"
    let latest = (http get https://api.github.com/repos/imputnet/helium-linux/releases/latest | get tag_name)
    let hash = (nix-prefetch-url $"https://github.com/imputnet/helium-linux/releases/download/($latest)/helium-($latest)-x86_64.AppImage" | str trim)
    let sri = (nix hash convert --hash-algo sha256 --to sri $hash | str trim)

    open $file
    | str replace --regex 'version = ".*?"' $'version = "($latest)"'
    | str replace --regex 'hash = ".*?"' $'hash = "($sri)"'
    | save --force $file

    print $"Bumped helium to ($latest) \(($sri)\)"
}

def update_flake [] {
    nix flake update
}

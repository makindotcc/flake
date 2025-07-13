#!/usr/bin/env nu

def main [] {
    main switch
}

def "main switch" [] {
    print "Switching..."
    nixos-rebuild --target-host makinx-deploy switch --flake ".#makincc" --sudo --ask-sudo-password
}

def "main test" [] {
    print "Running in test mode"
    nixos-rebuild --target-host makinx-deploy test --flake ".#makincc" --sudo --ask-sudo-password --impure
}

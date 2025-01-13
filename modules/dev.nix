{ pkgs, pkgs-master, ... }:
{
  environment.systemPackages =
    (with pkgs; [
    nixfmt-rfc-style
    cargo
    gleam
    go
    jdk
    nodejs_23
    gdb
    glib
    gnumake
    dconf2nix
    ])
    ++ (with pkgs-master; [
      opam
    ]);
}

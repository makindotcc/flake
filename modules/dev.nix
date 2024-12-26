{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    nixfmt-rfc-style
    cargo
    gleam
    go
    jdk
    nodejs_23
  ];
}

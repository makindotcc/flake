{
  config,
  lib,
  pkgs,
  modules,
  inputs,
  ...
}:
let
  stateVersion = "24.05";
in
{
  imports = [
    inputs.nixos-wsl.nixosModules.default
    ../../modules/system
    ../../modules/dev.nix
  ];
  home-manager.sharedModules = [ { home.stateVersion = stateVersion; } ];

  wsl.enable = true;
  wsl.defaultUser = "nixos";

  programs.nix-ld = {
    enable = true;
    package = pkgs.nix-ld-rs; # only for NixOS 24.05
  };

  networking.hostName = "pc-wsl";

  home-manager.users = {
    nixos = import ../../users/user/home.nix;
  };

  system.stateVersion = stateVersion;
}

{ config
, lib
, pkgs
, modules
, inputs
, ...
}:
let
  stateVersion = "24.05";
in
{
  imports = [
    inputs.nixos-wsl.nixosModules.default
    ../../modules/system.nix
    ../../modules/dev.nix
  ];

  wsl.enable = true;
  wsl.defaultUser = "nixos";

  programs.nix-ld = {
    enable = true;
    package = pkgs.nix-ld-rs; # only for NixOS 24.05
  };

  home-manager.users = {
    nixos = import ../../home/user/home.nix;
  };

  system.stateVersion = stateVersion;
}

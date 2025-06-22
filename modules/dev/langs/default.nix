{ lib, config, ... }:
{
  imports = [
    ./deprecated.nix
    ./gleam.nix
    ./go.nix
    ./java.nix
    ./js.nix
    ./nix.nix
    ./rust.nix
  ];

  options.dev.langs = {
    all = lib.mkEnableOption "Enable all development languages";
  };
}

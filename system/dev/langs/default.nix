{ lib, ... }:
{
  imports = [
    ./deprecated.nix
    ./gleam.nix
    ./go.nix
    ./java.nix
    ./js.nix
    ./nix.nix
    ./python.nix
    ./rust.nix
  ];

  options.dev.langs = {
    all = lib.mkEnableOption "Enable all development languages";
  };
}

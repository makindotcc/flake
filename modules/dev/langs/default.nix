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

  config = lib.mkIf config.dev.langs.all {
    dev.langs = {
      deprecated.enable = lib.mkDefault true;
      gleam.enable = lib.mkDefault true;
      go.enable = lib.mkDefault true;
      java.enable = lib.mkDefault true;
      js.enable = lib.mkDefault true;
      nix.enable = lib.mkDefault true;
      rust.enable = lib.mkDefault true;
    };
  };
}

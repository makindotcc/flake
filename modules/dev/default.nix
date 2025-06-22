{
  inputs,
  pkgs,
  pkgs-stable,
  lib,
  config,
  ...
}:
{
  imports = [
    ./langs
    ./programs.nix
  ];

  options.dev.full = lib.mkEnableOption "Enable all development modules";

  config = lib.mkIf config.dev.full {
    dev = {
      langs.all = lib.mkDefault true;
      programs.all = lib.mkDefault true;
    };
  };
}

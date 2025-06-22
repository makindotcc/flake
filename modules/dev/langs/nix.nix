{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.dev.langs.nix = {
    enable = lib.mkEnableOption "Nix programming language support";
  };

  config = lib.mkIf config.dev.langs.nix.enable {
    environment.systemPackages = with pkgs; [
      nixfmt-rfc-style
    ];
  };
}

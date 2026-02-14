{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.dev.langs.nix = {
    enable = lib.mkEnableDefaultOption config.dev.langs.all "Nix programming language support";
  };

  config = lib.mkIf config.dev.langs.nix.enable {
    environment.systemPackages = with pkgs; [
      nixfmt
      nil
    ];
  };
}

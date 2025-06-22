{
  config,
  pkgs,
  lib,
  ...
}:

{
  options.dev.langs.go = {
    enable = lib.mkEnableOption "Enable Go programming language support";
  };

  config = lib.mkIf config.dev.langs.go.enable {
    environment.systemPackages = [ pkgs.go ];
  };
}

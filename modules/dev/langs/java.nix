{
  config,
  lib,
  pkgs,
  ...
}:

{
  options.dev.langs.java = {
    enable = lib.mkEnableOption "Enable Java development";
  };

  config = lib.mkIf config.dev.langs.java.enable {
    environment.systemPackages = [ pkgs.jdk ];
  };
}

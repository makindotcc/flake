{
  config,
  lib,
  pkgs-stable,
  ...
}:

{
  options.dev.langs.java = {
    enable = lib.mkEnableDefaultOption config.dev.langs.all "Enable Java development";
  };

  config = lib.mkIf config.dev.langs.java.enable {
    environment.systemPackages = [ pkgs-stable.jdk ];
  };
}

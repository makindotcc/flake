{
  config,
  lib,
  pkgs,
  ...
}:

{
  options.dev.langs.js = {
    enable = lib.mkEnableOption "Enable js development";
  };

  config = lib.mkIf config.dev.langs.js.enable {
    environment.systemPackages = [ pkgs.nodejs ];
  };
}

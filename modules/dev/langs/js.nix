{
  config,
  lib,
  pkgs,
  ...
}:

{
  options.dev.langs.js = {
    enable = lib.mkEnableDefaultOption config.dev.langs.all "Enable js development";
  };

  config = lib.mkIf config.dev.langs.js.enable {
    environment.systemPackages = [ pkgs.nodejs ];
  };
}

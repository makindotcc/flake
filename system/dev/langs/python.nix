{
  config,
  pkgs,
  lib,
  ...
}:

{
  options.dev.langs.python = {
    enable = lib.mkEnableDefaultOption config.dev.langs.all "Enable Python programming language support";
  };

  config = lib.mkIf config.dev.langs.python.enable {
    environment.systemPackages = [
      pkgs.python3
    ];
  };
}

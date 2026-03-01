{
  config,
  lib,
  pkgs-stable,
  ...
}:
{
  options.dev.langs.deprecated = {
    enable = lib.mkEnableDefaultOption config.dev.langs.all "Deprecated programming languages support";
  };

  config = lib.mkIf config.dev.langs.deprecated.enable {
    environment.systemPackages = (
      with pkgs-stable;
      [
        gnumake
        lld
        gccgo
      ]
    );
  };
}

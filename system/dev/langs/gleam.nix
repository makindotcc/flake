{
  pkgs,
  lib,
  config,
  ...
}:
{
  options.dev.langs.gleam = {
    enable = lib.mkEnableDefaultOption config.dev.langs.all "Gleam programming language support";
  };

  config = lib.mkIf (config.dev.langs.gleam.enable) {
    environment.systemPackages = (
      with pkgs;
      [
        erlang
        rebar3
        inotify-tools
        gleam
      ]
    );
  };
}

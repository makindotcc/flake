{
  pkgs,
  pkgs-stable,
  lib,
  config,
  ...
}:
{
  options.dev.langs.gleam = {
    enable = pkgs.lib.mkEnableOption "Gleam programming language support";
  };

  config = lib.mkIf (config.dev.langs.gleam.enable) {
    environment.systemPackages =
      (with pkgs; [
        erlang
        rebar3
        inotify-tools
      ])
      ++ (with pkgs-stable; [
        gleam
      ]);
  };
}

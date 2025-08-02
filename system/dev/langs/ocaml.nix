{
  pkgs-stable,
  lib,
  config,
  ...
}:
{
  options.dev.langs.ocaml = {
    enable = lib.mkEnableDefaultOption config.dev.langs.all "OCaml programming language support";
  };

  config = lib.mkIf (config.dev.langs.ocaml.enable) {
    environment.systemPackages = [
      pkgs-stable.opam
    ];
  };
}

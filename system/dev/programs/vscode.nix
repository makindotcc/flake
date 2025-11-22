{
  lib,
  config,
  pkgs,
  ...
}:
{
  options.dev.programs.editor.vscode.enable =
    lib.mkEnableDefaultOption config.dev.programs.all "Enable Visual Studio Code";

  config =
    let
      cfg = config.dev.programs.editor.vscode;
    in
    lib.mkIf cfg.enable {
      environment.systemPackages = [
        pkgs.vscode
      ]
      ++ lib.optionals config.dev.langs.rust.enable [
        pkgs.rust-analyzer
        pkgs.rustfmt
      ];

      home-manager.sharedModules = [
        {
          programs.nushell.shellAliases.nixcfg = lib.mkIf cfg.enable "code ~/.config/nix";
        }
      ];
    };
}

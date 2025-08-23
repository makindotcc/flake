{
  pkgs,
  pkgs-stable,
  config,
  lib,
  ...
}:
let
  mkEnablePrograms = lib.mkEnableDefaultOption config.dev.programs.all;
in
{
  options.dev.programs = {
    all = lib.mkEnableOption "Enable all development programs";

    editor = {
      vscode.enable = mkEnablePrograms "Enable Visual Studio Code";
      idea.enable = mkEnablePrograms "Enable JetBrains Idea";
      clion.enable = mkEnablePrograms "Enable JetBrains CLion";
      rust-rover.enable = mkEnablePrograms "Enable Jetbrains RustRover";
    };
    re = {
      frida.enable = mkEnablePrograms "Enable Frida tools";
      ida.enable = mkEnablePrograms "Enable IDA";
      burp.enable = mkEnablePrograms "Enable Burp Suite";
    };
    debuggers = {
      gdb.enable = mkEnablePrograms "Enable GDB";
      lldb.enable = mkEnablePrograms "Enable LLDB";
    };
    devenv.enable = mkEnablePrograms "Enable devenv";
    direnv.enable = mkEnablePrograms "Enable direnv";
  };

  config =
    let
      cfg = config.dev.programs;
    in
    {
      environment.systemPackages = builtins.concatLists [
        (lib.optional cfg.editor.vscode.enable pkgs.vscode)
        (lib.optional cfg.editor.idea.enable pkgs-stable.jetbrains.idea-community-bin)
        (lib.optional cfg.editor.clion.enable pkgs-stable.jetbrains.clion)
        (lib.optional cfg.editor.rust-rover.enable pkgs-stable.jetbrains.rust-rover)
        (lib.optional cfg.re.frida.enable pkgs.frida-tools)
        (lib.optional cfg.re.ida.enable pkgs.ida-free)
        (lib.optional cfg.re.burp.enable pkgs.burpsuite)
        (lib.optional cfg.debuggers.gdb.enable pkgs.gdb)
        (lib.optional cfg.debuggers.lldb.enable pkgs.lldb)
        (lib.optional cfg.devenv.enable pkgs.devenv)
      ];

      programs.direnv.enable = cfg.direnv.enable;

      nix.extraOptions = lib.mkIf cfg.devenv.enable ''
        extra-substituters = https://devenv.cachix.org
        extra-trusted-public-keys = devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw=
      '';

      home-manager.sharedModules = [
        {
          programs = {
            nushell = {
              shellAliases.nixcfg = lib.mkIf cfg.editor.vscode.enable "code ~/.config/nix";
              extraConfig = lib.mkIf cfg.direnv.enable ''
                $env.config = {
                  hooks: {
                    pre_prompt: [{ ||
                      if (which direnv | is-empty) {
                        return
                      }

                      direnv export json | from json | default {} | load-env
                      if 'ENV_CONVERSIONS' in $env and 'PATH' in $env.ENV_CONVERSIONS {
                        $env.PATH = do $env.ENV_CONVERSIONS.PATH.from_string $env.PATH
                      }
                    }]
                  }
                }
              '';
            };
          };
        }
      ];
    };
}

{
  pkgs,
  config,
  lib,
  ...
}:
let
  mkEnableProgramsOption = lib.mkEnableDefaultOption config.dev.programs.all;
in
{
  options.dev.programs = {
    all = lib.mkEnableOption "Enable all development programs";

    editor = {
      vscode.enable = mkEnableProgramsOption "Enable Visual Studio Code";
      idea.enable = mkEnableProgramsOption "Enable JetBrains Idea";
      clion.enable = mkEnableProgramsOption "Enable JetBrains CLion";
    };
    re = {
      frida.enable = mkEnableProgramsOption "Enable Frida tools";
      ida.enable = mkEnableProgramsOption "Enable IDA";
      burp.enable = mkEnableProgramsOption "Enable Burp Suite";
    };
    debuggers = {
      gdb.enable = mkEnableProgramsOption "Enable GDB";
      lldb.enable = mkEnableProgramsOption "Enable LLDB";
    };
  };

  config =
    let
      cfg = config.dev.programs;
    in
    {
      environment.systemPackages = builtins.concatLists [
        (lib.optional cfg.editor.vscode.enable pkgs.vscode)
        (lib.optional cfg.editor.idea.enable pkgs.jetbrains.idea-community-bin)
        (lib.optional cfg.editor.clion.enable pkgs.jetbrains.clion)
        (lib.optional cfg.re.frida.enable pkgs.frida-tools)
        (lib.optional cfg.re.ida.enable pkgs.ida-free)
        (lib.optional cfg.re.burp.enable pkgs.burpsuite)
        (lib.optional cfg.debuggers.gdb.enable pkgs.gdb)
        (lib.optional cfg.debuggers.lldb.enable pkgs.lldb)
      ];

      home-manager.sharedModules = lib.mkIf cfg.editor.vscode.enable [
        {
          programs.nushell.shellAliases.nixcfg = "code ~/.config/nix";
        }
      ];
    };
}

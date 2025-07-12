{
  pkgs,
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
        (lib.optional cfg.editor.rust-rover.enable pkgs.jetbrains.rust-rover)
        (lib.optional cfg.re.frida.enable pkgs.frida-tools)
        (lib.optional cfg.re.ida.enable pkgs.ida-free)
        (lib.optional cfg.re.burp.enable pkgs.burpsuite)
        (lib.optional cfg.debuggers.gdb.enable pkgs.gdb)
        (lib.optional cfg.debuggers.lldb.enable pkgs.lldb)
      ];

      home-manager.sharedModules = [
        {
          programs = {
            nushell.shellAliases.nixcfg = lib.mkIf cfg.editor.vscode.enable "code ~/.config/nix";
          };
        }
      ];
    };
}

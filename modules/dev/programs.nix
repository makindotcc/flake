{
  pkgs,
  config,
  lib,
  ...
}:
{
  options.dev.programs = {
    all = lib.mkEnableOption "Enable all development programs";

    editor = {
      vscode.enable = pkgs.lib.mkEnableOption "Enable Visual Studio Code";
      idea.enable = pkgs.lib.mkEnableOption "Enable JetBrains Idea";
      clion.enable = pkgs.lib.mkEnableOption "Enable JetBrains CLion";
    };
    re = {
      frida.enable = lib.mkEnableOption "Enable Frida tools";
      ida.enable = lib.mkEnableOption "Enable IDA";
      burp.enable = lib.mkEnableOption "Enable Burp Suite";
    };
    debuggers = {
      gdb.enable = lib.mkEnableOption "Enable GDB";
      lldb.enable = lib.mkEnableOption "Enable LLDB";
    };
  };

  config =
    let
      cfg = config.dev.programs;
    in
    {
      dev.programs = lib.mkIf cfg.all {
        editor = {
          vscode.enable = lib.mkDefault true;
          idea.enable = lib.mkDefault true;
          clion.enable = lib.mkDefault true;
        };
        re = {
          frida.enable = lib.mkDefault true;
          ida.enable = lib.mkDefault true;
          burp.enable = lib.mkDefault true;
        };
        debuggers = {
          gdb.enable = lib.mkDefault true;
          lldb.enable = lib.mkDefault true;
        };
      };

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

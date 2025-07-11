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
      zed.enable = mkEnableProgramsOption "Enable Zed Editor";
      idea.enable = mkEnableProgramsOption "Enable JetBrains Idea";
      clion.enable = mkEnableProgramsOption "Enable JetBrains CLion";
      rust-rover.enable = mkEnableProgramsOption "Enable Jetbrains RustRover";
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
        (lib.optional cfg.editor.zed.enable pkgs.zed-editor)
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
            zed-editor = lib.mkIf cfg.editor.zed.enable {
              userSettings = {
                lsp = {
                  rust-analyzer = {
                    binary.path_lookup = true;
                  };
                };
              };
            };
          };
        }
      ];

      impermanence.normalUsers.directories = lib.mkIf cfg.editor.zed.enable [
        ".local/share/zed"
      ];
    };
}

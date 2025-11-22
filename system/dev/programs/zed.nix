{
  lib,
  config,
  pkgs,
  ...
}:
{
  options.dev.programs.editor.zed.enable =
    lib.mkEnableDefaultOption config.dev.programs.all "Enable Zed Editor";

  config = lib.mkIf config.dev.programs.editor.zed.enable {
    environment.systemPackages = [ pkgs.zed-editor ];

    impermanence.normalUsers.directories = [
      ".config/zed"
      ".local/share/zed"
    ];

    home-manager.sharedModules = [
      {
        programs.zed-editor = {
          enable = true;
          userSettings = {
            lsp = {
              rust-analyzer.binary = lib.mkIf config.dev.langs.rust.enable {
                path = lib.getExe pkgs.rust-analyzer;
              };
            };
            telemetry = {
              diagnostics = false;
              metrics = false;
            };
            base_keymap = "JetBrains";
            auto_update = false;
            preview_tabs.enabled = false;
            # minimap.show = "auto";
            buffer_font_family = "Comic Mono";
            features = {
              edit_prediction_provider = "copilot";
            };
          };
        };
      }
    ];
  };
}

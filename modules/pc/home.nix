{ pkgs, ... }:
{
  programs = {
    vscode = {
      enable = true;
      extensions = with pkgs; [
        vscode-extensions.jnoortheen.nix-ide
        vscode-extensions.k--kato.intellij-idea-keybindings
      ];
      userSettings = builtins.fromJSON (builtins.readFile ./config/vscode-userSettings.json);
    };
  };

  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
      clock-show-date = true;
      clock-show-seconds = true;
      clock-show-weekday = true;
    };
    "org/gnome/desktop/wm/preferences" = {
      resize-with-right-button = true;
      mouse-button-modifier = "<Super>";
    };
    "org/gnome/mutter" = {
      edge-tiling = true;
    };
    "org/gnome/desktop/peripherals/mouse" = {
      accel-profile = "flat";
    };
  };
}

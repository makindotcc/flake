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
    };
    "org/gnome/desktop/wm/preferences" = {
      resize-with-right-button = true;
      mouse-button-modifier = "<Super>";
    };
    "org/gnome/mutter" = {
      edge-tiling = true;
    };
  };
}

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
}

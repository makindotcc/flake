{
  pkgs,
  inputs,
  ...
}:
{
  imports = [
    ./xdg.nix
  ];

  # home.file.".mozilla/firefox/nix-user-profile/chrome/firefox-gnome-theme".source =
  #   inputs.firefox-gnome-theme;

  programs = {
    # idk, i'll use github sync ig?
    # vscode = {
    #   enable = true;
    #   extensions = with pkgs; [
    #     vscode-extensions.jnoortheen.nix-ide
    #     vscode-extensions.k--kato.intellij-idea-keybindings
    #     vscode-extensions.github.copilot
    #   ];
    #   userSettings = builtins.fromJSON (builtins.readFile ./config/vscode-userSettings.json);
    # };
    nushell = {
      enable = true;
      shellAliases = {
        nixcfg = "code ~/.config/nix";
      };
    };
    firefox = {
      enable = true;
      profiles.default = {
        # userChrome = ''
        #   @import "${inputs.firefox-gnome-theme}/userChrome.css";
        # '';
        # userContent = ''
        #   @import "${inputs.firefox-gnome-theme}/userContent.css";
        # '';
        settings = {
          "toolkit.legacyUserProfileCustomizations.stylesheets" = false;
          "browser.uidensity" = 0;
          "svg.context-properties.content.enabled" = true;
          "browser.theme.dark-private-windows" = false;
        };
      };
    };
  };
}

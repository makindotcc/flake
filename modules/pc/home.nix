{ pkgs, inputs, ... }:
{
  home.file.".mozilla/firefox/nix-user-profile/chrome/firefox-gnome-theme".source =
    inputs.firefox-gnome-theme;

  programs = {
    vscode = {
      enable = true;
      extensions = with pkgs; [
        vscode-extensions.jnoortheen.nix-ide
        vscode-extensions.k--kato.intellij-idea-keybindings
      ];
      userSettings = builtins.fromJSON (builtins.readFile ./config/vscode-userSettings.json);
    };
    nushell = {
      shellAliases = {
        nixcfg = "code ~/.config/nix";
      };
    };
    firefox = {
      enable = true;
      profiles.default = {
        userChrome = ''
          @import "${inputs.firefox-gnome-theme}/userChrome.css";
        '';
        userContent = ''
          @import "${inputs.firefox-gnome-theme}/userContent.css";
        '';
        settings = {
          "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
          "browser.uidensity" = 0;
          "svg.context-properties.content.enabled" = true;
          "browser.theme.dark-private-windows" = false;
        };
      };
    };
  };

  xdg.desktopEntries = {
    vesktop = {
      name = "vesktop";
      exec = "vesktop --enable-accelerated-mjpeg-decode --enable-accelerated-video --ignore-gpu-blacklist --enable-native-gpu-memory-buffers --enable-gpu-rasterization";
    };
  };

  programs.gnome-shell = {
    enable = true;
    extensions = with pkgs.gnomeExtensions; [
      { package = appindicator; }
      { package = caffeine; }
      { package = media-progress; }
      { package = rounded-window-corners-reborn; }
      { package = window-is-ready-remover; }
    ];
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
      button-layout = "appmenu:minimize,maximize,close";
    };
    "org/gnome/mutter" = {
      edge-tiling = true;
      experimental-features = [ "scale-monitor-framebuffer" ];
    };
    "org/gnome/desktop/peripherals/mouse" = {
      accel-profile = "flat";
    };
    "org/gnome/shell/extensions/appindicator" = {
      icon-saturation = 1.0;
      legacy-tray-enabled = true;
    };
  };
}

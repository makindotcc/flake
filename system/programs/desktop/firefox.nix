_: {
  home-manager.sharedModules = [
    {
      programs.firefox = {
        enable = true;
        profiles.default = {
          settings = {
            "toolkit.legacyUserProfileCustomizations.stylesheets" = false;
            "browser.uidensity" = 0;
            "svg.context-properties.content.enabled" = true;
            "browser.theme.dark-private-windows" = false;
          };
        };
      };
    }
  ];
}

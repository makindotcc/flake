{ lib, config, ... }:
{
  options.programs.firefox-hm.enable = lib.mkEnableOption "Firefox with home manager" // {
    default = config.isDesktop;
  };

  config = lib.mkIf config.programs.firefox-hm.enable {
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
  };
}

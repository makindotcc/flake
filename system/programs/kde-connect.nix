{
  pkgs,
  lib,
  config,
  ...
}:
{
  options.programs.kde-connect.enable = lib.mkEnableOption "KDE Connect" // {
    default = config.isLinux && config.isPersonalPuter;
  };

  config = lib.mkIf config.programs.kde-connect.enable {
    networking.firewall = rec {
      allowedTCPPortRanges = [
        {
          from = 1714;
          to = 1764;
        }
      ];
      allowedUDPPortRanges = allowedTCPPortRanges;
    };

    home-manager.sharedModules =
      let
        gnomeSetup = lib.optionals config.services.desktopManager.gnome.enable [
          {
            programs.gnome-shell = {
              extensions = [ { package = pkgs.gnomeExtensions.gsconnect; } ];
            };

            dconf.settings = {
              "org/gnome/shell/extensions/gsconnect/device/76a91033_c49b_492f_a0e7_39ffa40c9a93/plugin/clipboard" =
                {
                  receive-content = true;
                  send-content = true;
                };
            };
          }
        ];
        kdeSetup = lib.optionals config.services.desktopManager.plasma6.enable [
          {
            services.kdeconnect.enable = true;
          }
        ];
      in
      gnomeSetup ++ kdeSetup;
  };
}

{ pkgs, ... }:
{
  networking.firewall = rec {
    allowedTCPPortRanges = [
      {
        from = 1714;
        to = 1764;
      }
    ];
    allowedUDPPortRanges = allowedTCPPortRanges;
  };

  home-manager.sharedModules = [
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
}

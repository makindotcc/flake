{
  lib,
  pkgs,
  config,
  ...
}:
let
  screenInactivity = {
    timeoutSeconds = 900;
    # gnome has screen dimming animation that takes x seconds,
    # add some extra time to make sure screen animation is finished
    # before turning off the screen completely.
    fadeoutSeconds = 15;
  };
in
lib.mkIf config.isDesktop {
  services.xserver.displayManager.setupCommands = ''
    echo "xset dpms 0 0 ${
      toString (screenInactivity.timeoutSeconds + screenInactivity.fadeoutSeconds)
    }" | systemd-cat
    sleep 10
    ${pkgs.xorg.xset}/bin/xset -dpms
    ${pkgs.xorg.xset}/bin/xset +dpms
    ${pkgs.xorg.xset}/bin/xset dpms 0 0 ${
      toString (screenInactivity.timeoutSeconds + screenInactivity.fadeoutSeconds)
    }
  '';

  home-manager.sharedModules = [
    (
      { lib, ... }:
      with lib.hm.gvariant;
      {
        dconf.settings = {
          # power management
          ## don't suspend
          "org/gnome/settings-daemon/plugins/power" = {
            sleep-inactive-ac-type = "nothing";
          };

          ## lock/blank after 15 mins
          "org/gnome/desktop/session" = {
            idle-delay = mkUint32 screenInactivity.timeoutSeconds;
          };
        };
      }
    )
  ];
}

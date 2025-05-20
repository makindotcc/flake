{
  lib,
  pkgs,
  inputs,
  ...
}:
with lib.hm.gvariant;
let
  screenInactivity = {
    timeoutSeconds = 900;
    # gnome has screen dimming animation that takes x seconds,
    # add some extra time to make sure screen animation is finished
    # before turning off the screen completely.
    fadeoutSeconds = 15;
  };
in
{
  # for some reason AFTER RESUME IT FUCKING STARTS
  # SHUTTING DOWN THE MONITOR AFTER 30 SECONDS OF INACTIVITY??????
  powerManagement.resumeCommands = ''
    ${pkgs.xorg.xset}/bin/xset -dpms
    ${pkgs.xorg.xset}/bin/xset +dpms
    ${pkgs.xorg.xset}/bin/xset dpms 0 0 ${
      screenInactivity.timeoutSeconds + screenInactivity.fadeoutSeconds
    }
  '';

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

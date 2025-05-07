{
  lib,
  osConfig,
  ...
}:
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
      idle-delay = mkUint32 900;
    };
  };
}

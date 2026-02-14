{
  pkgs,
  lib,
  config,
  ...
}:
{
  options.programs.chrome.enable = lib.mkEnableOption "Google Chrome browser" // {
    default = config.isDesktop;
  };
  config = lib.mkIf config.programs.chrome.enable {
    environment.systemPackages = [ pkgs.google-chrome ];
    impermanence.normalUsers.directories = [ ".config/google-chrome" ];

    # allow usb access for chrome (e.g. usevia.app)
    services.udev.extraRules = ''
      KERNEL=="hidraw*", SUBSYSTEM=="hidraw", MODE="0666", TAG+="uaccess", TAG+="udev-acl"
    '';
  };
}

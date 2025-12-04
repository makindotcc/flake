{
  lib,
  config,
  pkgs-stable,
  ...
}:
{
  options.dev.programs.androidstudio = {
    enable = lib.mkEnableDefaultOption config.dev.programs.all "Enable Android Studio IDE";
  };

  config = lib.mkIf config.dev.programs.androidstudio.enable {
    environment.systemPackages = [
      pkgs-stable.android-tools
      pkgs-stable.android-studio
    ];
    impermanence.normalUsers.directories = [
      "Android"
      ".android"
    ];

    programs.adb.enable = true;

    users.users.user.extraGroups = [ "adbusers" ];
  };
}

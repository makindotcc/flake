{
  pkgs,
  config,
  lib,
  ...
}:
let
  mkEnableGamingOption = lib.mkEnableDefaultOption config.gaming.full;
in
{
  options.gaming = {
    full = lib.mkEnableOption "Enable all gaming modules";

    enable = mkEnableGamingOption "Enable gaming support";
    minecraft = {
      lunar-client.enable = mkEnableGamingOption "Enable Lunar Client for Minecraft";
      prismlauncher.enable = mkEnableGamingOption "Enable Prism Launcher for Minecraft";
    };
    steam.enable = mkEnableGamingOption "Enable Steam";
  };

  config =
    let
      cfg = config.gaming;
    in
    lib.mkIf cfg.enable {
      programs.gamemode.enable = true;

      environment.systemPackages = builtins.concatLists [
        (lib.optional cfg.minecraft.lunar-client.enable pkgs.lunar-client)
        (lib.optional cfg.minecraft.prismlauncher.enable (
          pkgs.prismlauncher.override {
            jdks = [
              pkgs.jdk8
              pkgs.jdk21
            ];
          }
        ))
      ];

      programs.steam = lib.mkIf cfg.steam.enable {
        enable = true;
        extest.enable = true;
        protontricks.enable = true;
        extraCompatPackages = [ pkgs.proton-ge-bin ];
        extraPackages = with pkgs; [
          steamtinkerlaunch
          winetricks
        ];
        gamescopeSession.enable = true;
      };
    };
}

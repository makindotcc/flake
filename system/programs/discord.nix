{
  pkgs,
  lib,
  config,
  ...
}:
{
  options.programs.discord.enable = lib.mkEnableOption "Discord client" // {
    default = config.isPersonalPuter;
  };

  config = lib.mkIf config.programs.discord.enable {
    environment.systemPackages = [
      pkgs.discord
      pkgs.vesktop
    ];

    impermanence.normalUsers.directories = [
      ".config/discord"
      ".config/vesktop"
    ];
  };
}

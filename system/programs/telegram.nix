{
  pkgs,
  lib,
  config,
  ...
}:
{
  options.programs.telegram.enable = lib.mkEnableOption "Telegram desktop client" // {
    default = config.isPersonalPuter;
  };

  config = lib.mkIf config.programs.telegram.enable {
    environment.systemPackages = [
      (pkgs.telegram-desktop.override { withWebkit = false; })
    ];
    impermanence.normalUsers.directories = [
      ".local/share/TelegramDesktop"
    ];
  };
}

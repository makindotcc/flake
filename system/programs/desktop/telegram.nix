{ pkgs, ... }:
{
  environment.systemPackages = [
    (pkgs.telegram-desktop.override { withWebkit = false; })
  ];
  impermanence.normalUsers.directories = [
    ".local/share/TelegramDesktop"
  ];
}

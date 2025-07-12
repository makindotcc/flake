{ pkgs, ... }:
{
  environment.systemPackages = [
    (pkgs.telegram-desktop.override { withWebkit = false; })
  ];
  environment.persistence.normalUsers.directories = [
    ".local/share/TelegramDesktop"
  ];
}

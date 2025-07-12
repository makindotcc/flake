{ pkgs, ... }:
{
  environment.systemPackages = [
    pkgs.discord
    pkgs.vesktop
  ];

  environment.persistence.normalUsers.directories = [
    ".config/discord"
    ".config/vesktop"
  ];
}

{ pkgs, ... }:
{
  environment.systemPackages = [
    pkgs.discord
    pkgs.vesktop
  ];

  impermanence.normalUsers.directories = [
    ".config/discord"
    ".config/vesktop"
  ];
}

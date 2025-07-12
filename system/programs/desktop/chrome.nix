{ pkgs, ... }:
{
  environment.systemPackages = [ pkgs.google-chrome ];
  impermanence.normalUsers.directories = [ ".config/google-chrome" ];
}

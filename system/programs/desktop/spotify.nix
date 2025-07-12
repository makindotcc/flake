{ pkgs, ... }:
{
  environment.systemPackages = [ pkgs.spotify ];
  impermanence.normalUsers.directories = [ ".config/spotify" ];
}

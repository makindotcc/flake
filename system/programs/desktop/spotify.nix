{ pkgs, ... }:
{
  environment.systemPackages = [ pkgs.spotify ];
  environment.persistence.normalUsers.directories = [ ".config/spotify" ];
}

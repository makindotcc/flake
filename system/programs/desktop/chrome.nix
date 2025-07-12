{ pkgs, ... }:
{
  environment.systemPackages = [ pkgs.google-chrome ];
  environment.persistence.normalUsers.directories = [ ".config/google-chrome" ];
}

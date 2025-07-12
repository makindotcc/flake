{ pkgs, ... }:
{
  environment.systemPackages = [ pkgs.signal-desktop ];
  environment.persistence.normalUsers.directories = [ ".config/Signal" ];
}

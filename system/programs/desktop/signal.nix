{ pkgs, ... }:
{
  environment.systemPackages = [ pkgs.signal-desktop ];
  impermanence.normalUsers.directories = [ ".config/Signal" ];
}

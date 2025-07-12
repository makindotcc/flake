{ pkgs, ... }:
{
  environment.systemPackages = [ pkgs.slack ];
  impermanence.normalUsers.directories = [ ".config/Slack" ];
}

{ pkgs, ... }:
{
  environment.systemPackages = [ pkgs.slack ];
  environment.persistence.normalUsers.directories = [ ".config/Slack" ];
}

{
  pkgs,
  lib,
  config,
  ...
}:
{
  options.programs.slack.enable = lib.mkEnableOption "Slack" // {
    default = config.isPersonalPuter;
  };

  config = lib.mkIf config.programs.parsec.enable {
    environment.systemPackages = [ pkgs.slack ];
    impermanence.normalUsers.directories = [ ".config/Slack" ];
  };
}

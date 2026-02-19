{
  config,
  lib,
  pkgs,
  ...
}:
{
  config = {
    programs.wireshark.enable = config.isPersonalPuter;
    programs.wireshark.package = lib.mkIf config.isPersonalPuter pkgs.wireshark;
    users.users.user.extraGroups = lib.mkIf config.isPersonalPuter [ "wireshark" ];
  };
}

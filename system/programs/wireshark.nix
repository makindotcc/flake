{
  config,
  lib,
  pkgs,
  ...
}:
{
  config = lib.mkIf config.isPersonalPuter {
    programs.wireshark.enable = true;
    programs.wireshark.package = pkgs.wireshark;
    users.users.user.extraGroups = [ "wireshark" ];
  };
}

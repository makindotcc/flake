{
  config,
  lib,
  ...
}:
{
  config = {
    programs.wireshark.enable = lib.mkDefault (config.isPhysical && config.isDesktop);
  };
}

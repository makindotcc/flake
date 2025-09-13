{ config, ... }:
{
  config = {
    programs.wireshark.enable = config.isPersonalPuter;
  };
}

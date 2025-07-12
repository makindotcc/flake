{ lib, config, ... }:
{
  programs.firefox.enable = lib.mkDefault config.isDesktop;
}

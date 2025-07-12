{ pkgs, config, ... }:
{
  services.mullvad-vpn = {
    enable = true;
    package = pkgs.mullvad-vpn;
  };
  environment.persistence.${config.impermanence.dir}.directories = [
    "/etc/mullvad-vpn"
  ];
  impermanence.normalUsers.directories = [
    ".config/Mullvad VPN"
  ];
}

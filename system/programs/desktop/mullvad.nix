{ pkgs, config, ... }:
{
  services.mullvad-vpn = {
    enable = true;
    package = pkgs.mullvad-vpn;
  };
  environment.persistence = {
    ${config.environment.persistence.dir} = {
      directories = [
        "/etc/mullvad-vpn"
      ];
    };
    normalUsers.directories = [
      ".config/Mullvad VPN"
    ];
  };
}

{ pkgs, config, ... }:
{
  options.programs.mullvad.enable = pkgs.lib.mkEnableOption "Mullvad VPN client" // {
    default = config.isPersonalPuter;
  };

  config = pkgs.lib.mkIf config.programs.mullvad.enable {
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
  };
}

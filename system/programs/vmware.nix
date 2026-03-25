{
  config,
  lib,
  pkgs-stable,
  ...
}:
{
  options.programs.vmware.enable = lib.mkEnableOption "Enable VMware support" // {
    default = config.isPersonalPuter;
  };

  config = lib.mkIf config.programs.vmware.enable {
    virtualisation.vmware.host = {
      enable = true;
      package = pkgs-stable.vmware-workstation;
    };
    impermanence.normalUsers.directories = [ "vmware" ];
    environment.persistence.${config.impermanence.dir}.directories = [
      "/etc/vmware" # crashuje ? chjyba vmware przez to
    ];
  };
}

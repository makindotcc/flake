{ config, lib, ... }:
{
  options.programs.vmware.enable = lib.mkEnableOption "Enable VMware support" // {
    default = config.isPersonalPuter;
  };

  config = lib.mkIf config.programs.vmware.enable {
    virtualisation.vmware.host.enable = true;
    impermanence.normalUsers.directories = [ "vmware" ];
  };
}

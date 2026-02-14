{ config, lib, ... }:
{
  options.docker.enable = lib.mkEnableOption "Enable Docker support";
  config = lib.mkIf config.docker.enable {
    virtualisation.docker = {
      enable = true;
      enableOnBoot = false;
    };
    environment.persistence.${config.impermanence.dir}.directories = [ "/root/.docker" ];

  };
}

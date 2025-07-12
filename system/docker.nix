{ config, lib, ... }:
{
  options.docker.enable = lib.mkEnableOption "Enable Docker support";
  config = lib.mkIf config.docker.enable {
    virtualisation.docker.enable = true;
    environment.persistence.${config.environment.persistence.dir}.directories = [ "/root/.docker" ];
  };
}

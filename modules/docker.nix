{ config, ... }:
{
  virtualisation.docker.enable = true;
  environment.persistence.${config.impermanence.dir}.directories = [ "/root/.docker" ];
}

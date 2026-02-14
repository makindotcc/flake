{ config, lib, ... }:
{
  services.tabby = {
    enable = false;
    acceleration = "cuda";
    model = "Codestral-22B";
    port = 11029;
  };

  systemd.services.tabby.wantedBy = lib.mkForce [ ];

  environment.persistence.${config.impermanence.dir}.directories = [ "/var/lib/private/tabby" ];
}

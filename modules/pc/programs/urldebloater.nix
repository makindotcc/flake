{ inputs, pkgs, ... }:
{
  # environment.systemPackages = [
  #   inputs.urldebloater.packages.${pkgs.system}.urldebloater
  # ];

  # systemd.user.services.urldebloater = {
  #   enable = true;
  #   description = "Run urldebloater at startup";
  #   after = [ "network.target" ];
  #   wantedBy = [ "default.target" ];
  #   serviceConfig = {
  #     ExecStart = "${inputs.urldebloater.packages.${pkgs.system}.urldebloater}/bin/urldebloater";
  #     Restart = "on-failure";
  #   };
  # };
}

{
  self,
  config,
  pkgs,
  ...
}:
{
  environment.systemPackages = [ pkgs.tailscale ];
  services.tailscale = {
    enable = true;
    authKeyFile = config.age.secrets.tailscale-authkey.path;
  };
  age.secrets.tailscale-authkey.file = self + /secrets/tailscale-authkey.age;

  networking.firewall = {
    enable = true;
    trustedInterfaces = [ "tailscale0" ];
    allowedUDPPorts = [ config.services.tailscale.port ];
  };
}

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
    authKeyFile = config.age.secrets.tailscale-pc.path;
  };
  age.secrets.tailscale-pc.file = self + /secrets/tailscale-pc.age;

  networking.firewall = {
    enable = true;
    trustedInterfaces = [ "tailscale0" ];
    allowedUDPPorts = [ config.services.tailscale.port ];
  };
}

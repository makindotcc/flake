{ pkgs, config, ... }:
{
  services.caddy = {
    enable = true;
    enableReload = false;
    globalConfig = ''
      admin off
    '';
    virtualHosts."http://xd.firma.sex.pl".extraConfig = ''
      respond "Hello, world!"
    '';
  };

  environment.systemPackages = [ pkgs.cloudflared ];
  services.cloudflared = {
    enable = true;
    package = pkgs.cloudflared;
    certificateFile = config.age.secrets.cf-cert.path;
    tunnels = {
      "d46659f4-ff43-46e6-a94b-3c5afef7d4ca" = {
        credentialsFile = config.age.secrets.cf-tunnel.path;
        default = "http_status:404";
        ingress = {
          "xd.firma.sex.pl" = {
            service = "http://localhost:80";
          };
        };
      };
    };
  };

  age.secrets.cf-tunnel.file = ../../secrets/cf-tunnel.age;
}

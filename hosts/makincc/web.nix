_: {
  services.caddy = {
    enable = true;
    enableReload = false;
    globalConfig = ''
      admin off
    '';
    virtualHosts."localhost".extraConfig = ''
      respond "Hello, world!"
    '';
  };
  services.cloudflared = {
    enable = true;
  };
}

_: {
  services.caddy = {
    enable = true;
    enableReload = false;
    globalConfig = ''
      admin off
    '';
  };
  services.cloudflared = {
    enable = true;
  };
}

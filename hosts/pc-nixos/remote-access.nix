{ inputs, ... }:
{
  services.openssh = {
    enable = true;
    ports = [ 2135 ];
    settings.PasswordAuthentication = false;
    settings.KbdInteractiveAuthentication = false;
    settings.PermitRootLogin = "no";
  };

  programs.mosh = {
    enable = true;
    openFirewall = true;
  };

  home-manager.users.user = {
    imports = [
      (inputs.vscode-server + /modules/vscode-server/home.nix)
    ];
    services.vscode-server.enable = true;
  };
}

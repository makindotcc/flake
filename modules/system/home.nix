{ ... }:
{
  imports = [ ./dconf.nix ];

  programs = {
    git.enable = true;
    home-manager.enable = true;
    nushell = {
      enable = true;
      configFile.source = ./nushell/config.nu;
    };
  };

  services.pueue.enable = true;
}

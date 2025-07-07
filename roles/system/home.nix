{ ... }:
{
  programs = {
    git.enable = true;
    home-manager.enable = true;
    nushell = {
      enable = true;
      configFile.source = ./nushell/config.nu;
    };
    zsh.enable = true;
    ssh.enable = true;
  };

  services.pueue.enable = true;

  home.shell.enableNushellIntegration = true;
}

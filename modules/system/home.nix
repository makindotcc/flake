{ ... }: {
  programs = {
    git.enable = true;
    home-manager.enable = true;
    nushell = {
      enable = true;
      configFile.source = ./nushell_config.nu;
    };
  };
  home.stateVersion = "24.05";
}

{ pkgs, ... }:
{
  users.defaultUserShell = pkgs.nushell;
  environment.shells = [
    pkgs.nushell
  ];

  home-manager.sharedModules = [
    {
      programs = {
        nushell = {
          enable = true;
          configFile.source = ./config.nu;
        };
        zsh.enable = true;
      };
      home.shell.enableNushellIntegration = true;
    }
  ];
}

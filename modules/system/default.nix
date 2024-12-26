{ config, inputs, pkgs, ... }: {
  imports = [
    inputs.home-manager.nixosModules.home-manager
  ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  environment.systemPackages = with pkgs; [
    git
    vim
    nushell
    neofetch
    wget
    tmux
  ];

  users.defaultUserShell = pkgs.nushell;

  home-manager.sharedModules = [
    {
      programs = {
        nushell = {
          enable = true;
          configFile.source = ./nushell_config.nu;
        };
      };
    }
  ];
}
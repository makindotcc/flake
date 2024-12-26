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
  ];

  users.defaultUserShell = pkgs.nushell;
}

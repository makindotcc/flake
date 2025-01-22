{
  config,
  inputs,
  pkgs,
  ...
}:
{
  imports = [
    inputs.home-manager.nixosModules.home-manager
  ];

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    git
    vim
    wget
    tmux
    bat
    file
    ncdu
    ouch
    bottom
    fastfetch
    psmisc
    doggo
    inetutils
    nmap
    speedtest-go
  ];

  networking.nameservers = [
    "1.1.1.1"
    "8.8.8.8"
  ];

  users.defaultUserShell = pkgs.nushell;
  environment.shells = [
    pkgs.nushell
  ];

  home-manager.sharedModules = [ (import ./home.nix) ];
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.backupFileExtension = "hm-backup";
}

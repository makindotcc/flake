{
  inputs,
  pkgs,
  config,
  lib,
  ...
}:
{
  imports = [
    inputs.home-manager.nixosModules.home-manager
    inputs.agenix.nixosModules.default
    inputs.impermanence.nixosModules.impermanence
  ];

  options = {
    impermanence = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
      };
      dir = lib.mkOption {
        type = lib.types.str;
        default = "/persistent";
      };
    };
  };

  config = {
    environment.persistence.${config.impermanence.dir}.enable = config.impermanence.enable;

    nix.settings.experimental-features = [
      "nix-command"
      "flakes"
      "pipe-operators"
    ];

    nixpkgs.config.allowUnfree = true;

    environment.systemPackages =
      (with pkgs; [
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
      ])
      ++ [
        inputs.agenix.packages.${pkgs.system}.default
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

    security.sudo.extraConfig = ''
      Defaults lecture="never"
    '';
  };
}

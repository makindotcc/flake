{
  inputs,
  pkgs,
  lib,
  config,
  ...
}:
{
  imports = [
    inputs.home-manager.nixosModules.home-manager
    inputs.agenix.nixosModules.default
    ./de
    ./dev
    ./hardware
    ./programs
    ./shell
  ]
  ++ (lib.collectNix ./. |> lib.remove ./default.nix);

  options = {
    isDesktop = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether this is a desktop system.";
    };
    isPhysical = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether this is a physical system.";
    };
    isPersonalPuter = lib.mkOption {
      type = lib.types.bool;
      default = config.isDesktop && config.isPhysical;
      description = "Whether this is a personal computer.";
    };
    os = lib.mkConst <| lib.last <| lib.splitString "-" config.nixpkgs.hostPlatform.system;
    isLinux = lib.mkConst (config.os == "linux");
  };

  config = {
    nix.settings.experimental-features = [
      "nix-command"
      "flakes"
      "pipe-operators"
    ];

    nixpkgs.config.allowUnfree = true;

    environment.systemPackages = [
      inputs.agenix.packages.${pkgs.system}.default
    ];

    networking.nameservers = [
      "1.1.1.1"
      "8.8.8.8"
    ];
    services.resolved = {
      enable = true;
      settings.Resolve.DNSSEC = "false";
    };

    home-manager.useGlobalPkgs = true;
    home-manager.useUserPackages = true;
    home-manager.backupFileExtension = "hm-backup";
    home-manager.sharedModules = [
      {
        programs = {
          home-manager.enable = true;
          git.enable = true;
          ssh = {
            enable = true;
            enableDefaultConfig = false;
            matchBlocks."*" = {
              serverAliveInterval = 120;
            };
          };
        };
      }
    ];

    security.sudo.extraConfig = ''
      Defaults lecture="never"
    '';

    # programs.nix-ld.enable = true;

    # graphene hardened malloc
    boot.kernel.sysctl."vm.max_map_count" = lib.mkIf config.isLinux 1048576;
  };
}

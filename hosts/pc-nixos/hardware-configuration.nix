{
  config,
  lib,
  ...
}:
{
  boot.kernelModules = [
    "kvm-amd"
    "nct6775"
  ];
  boot.extraModprobeConfig = ''
    options nct6775 force_id=0xd420
  '';
  boot.initrd.kernelModules = [ "nct6775" ];
  boot.initrd.availableKernelModules = [
    "nvme"
    "xhci_pci"
    "ahci"
    "usbhid"
    "usb_storage"
    "sd_mod"
  ];
  boot.extraModulePackages = [ ];

  boot.initrd.luks.devices."luks-59700f93-fba1-480f-b5c5-621cc847f68f".device =
    "/dev/disk/by-uuid/59700f93-fba1-480f-b5c5-621cc847f68f";

  fileSystems = {
    "/" = {
      device = "none";
      fsType = "tmpfs";
      options = [
        "defaults"
        "size=25%"
        "mode=755"
      ];
    };
    ${config.impermanence.dir} = {
      device = "/dev/disk/by-uuid/96dd4e43-27fc-4cd2-9c1b-13de02ee4853";
      fsType = "ext4";
      neededForBoot = true;
    };
    "/boot" = {
      device = "/dev/disk/by-uuid/8D0A-3581";
      fsType = "vfat";
      options = [
        "fmask=0077"
        "dmask=0077"
      ];
    };
    "/etc/ssh".neededForBoot = true;
  };

  impermanence.enable = true;
  environment.persistence.${config.impermanence.dir} = {
    hideMounts = true;
    directories = [
      "/var/log"
      "/var/lib"
      "/nix"
      "/etc/ssh"
      "/etc/nixos"
      "/etc/NetworkManager/system-connections"
    ];
    files = [
      "/etc/machine-id"
    ];
    users.user = {
      files = [
        ".bash_history"
        ".config/monitors.xml"
      ];
      directories = [
        "Downloads"
        "Music"
        "Pictures"
        "Documents"
        "Videos"
        "Desktop"
        {
          directory = ".gnupg";
          mode = "0700";
        }
        {
          directory = ".ssh";
          mode = "0700";
        }
        # todo: each nix file responsible for installing program should declare
        # its own persistence
        ".local/share/Steam"
        ".local/share/Trash"
        ".local/share/docker"
        ".local/share/lutris"
        ".local/share/PrismLauncher"
        ".local/share/JetBrains"
        ".local/share/fsearch"
        ".local/share/krita"
        ".local/share/nautilus"
        {
          directory = ".local/share/keyrings";
          mode = "0700";
        }
        ".local/share/nix"
        ".local/share/kotlin"
        ".config/nix"
        ".config/Code"
        ".config/chromium"
        ".config/JetBrains"
        ".config/nushell"
        ".config/ngrok"
        ".config/fsearch"
        ".config/ghostty"
        ".cache"
        ".BurpSuite"
        ".cargo"
        ".rustup"
        ".gradle"
        ".minecraft"
        ".mozilla"
        "Games"
        ".lunarclient"
        ".vscode"
        ".npm"
        ".m2"
        ".java"
        ".docker"
        ".pki"
        ".idapro"
        ".steam"
        ".nuget"
      ];
    };
  };

  swapDevices = [ ];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.eno1.useDHCP = lib.mkDefault true;
  # networking.interfaces.wlp11s0.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}

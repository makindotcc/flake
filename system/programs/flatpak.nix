{ config, lib, ... }:
lib.mkIf config.isDesktop {
  services.flatpak.enable = true;

  impermanence.normalUsers.directories = [
    ".local/share/flatpak"
    ".var"
  ];
  environment.persistence.${config.impermanence.dir}.directories = [
    "/var/lib/flatpak"
  ];
}

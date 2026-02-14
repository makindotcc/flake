{ pkgs, ... }:
{
  environment.systemPackages = [ pkgs.nautilus ];

  # Needed for Nautilus to work properly outside GNOME
  services.gvfs.enable = true;

  impermanence.normalUsers.directories = [
    ".local/share/nautilus"
    ".config/nautilus"
  ];
}

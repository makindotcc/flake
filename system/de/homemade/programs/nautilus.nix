{ pkgs, ... }:
{
  environment.systemPackages = [ pkgs.nautilus ];

  # Needed for Nautilus to work properly outside GNOME
  services.gvfs.enable = true;

  home-manager.sharedModules = [
    {
      dconf.settings."org/gnome/nautilus/preferences" = {
        default-folder-viewer = "list-view";
      };
    }
  ];

  impermanence.normalUsers.directories = [
    ".local/share/nautilus"
    ".config/nautilus"
  ];
}

{
  pkgs,
  lib,
  config,
  ...
}:
{
  options.programs.spotify.enable = lib.mkEnableOption "Spotify" // {
    default = config.isPersonalPuter;
  };

  config = lib.mkIf config.programs.spotify.enable {
    environment.systemPackages = [ pkgs.spotify ];
    impermanence.normalUsers.directories = [ ".config/spotify" ];
  };
}

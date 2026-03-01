{
  pkgs,
  lib,
  config,
  ...
}:
{
  options.programs.obs.enable = lib.mkEnableOption "OBS Studio" // {
    default = config.isPersonalPuter;
  };

  config = lib.mkIf config.programs.obs.enable {
    programs.obs-studio = {
      enable = true;
      package = (
        pkgs.obs-studio.override {
          cudaSupport = true;
        }
      );
      plugins = with pkgs.obs-studio-plugins; [
        obs-vaapi
        obs-pipewire-audio-capture
      ];
    };

    impermanence.normalUsers.directories = [ ".config/obs-studio" ];
  };
}

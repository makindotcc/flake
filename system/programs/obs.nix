{
  pkgs-stable,
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
        pkgs-stable.obs-studio.override {
          cudaSupport = true;
        }
      );
    };

    impermanence.normalUsers.directories = [ ".config/obs-studio" ];
  };
}

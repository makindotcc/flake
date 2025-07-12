{ pkgs, ... }:
{
  programs.obs-studio = {
    enable = true;
    package = (
      pkgs.obs-studio.override {
        cudaSupport = true;
      }
    );
  };

  environment.persistence.normalUsers.directories = [ ".config/obs-studio" ];
}

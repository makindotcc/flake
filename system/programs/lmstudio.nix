{
  pkgs,
  lib,
  config,
  ...
}:
{
  options.programs.lmstudio.enable = lib.mkEnableOption "LMStudio" // {
    default = config.isPersonalPuter;
  };

  config = lib.mkIf config.programs.lmstudio.enable {
    environment.systemPackages = [
      pkgs.lmstudio
    ];

    impermanence.normalUsers.directories = [
      ".cache/lm-studio"
    ];
  };
}

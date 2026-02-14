{
  pkgs,
  pkgs-stable,
  lib,
  config,
  ...
}:
{
  options.programs.sublime.enable = lib.mkEnableOption "Sublime Text editor" // {
    default = config.isDesktop;
  };

  config = lib.mkIf config.programs.sublime.enable ({
    nixpkgs.overlays = [
      (final: prev: {
        teamspeak3-insecure = pkgs-stable.teamspeak3;
      })
    ];
    environment.systemPackages = [ pkgs.sublime4 ];
    impermanence.normalUsers.directories = [ ".config/sublime-text" ];
    nixpkgs.config.permittedInsecurePackages = [ "openssl-1.1.1w" ];
  });
}

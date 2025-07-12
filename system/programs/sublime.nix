{
  pkgs,
  lib,
  config,
  ...
}:
{
  options.programs.sublime.enable = lib.mkEnableOption "Sublime Text editor" // {
    default = config.isDesktop;
  };

  config = lib.mkIf config.programs.sublime.enable {
    environment.systemPackages = [ pkgs.sublime4 ];
    nixpkgs.config.permittedInsecurePackages = [ "openssl-1.1.1w" ];
    impermanence.normalUsers.directories = [ ".config/sublime-text" ];
  };
}

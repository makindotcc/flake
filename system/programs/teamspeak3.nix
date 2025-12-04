{
  pkgs-stable,
  lib,
  config,
  ...
}:
{
  options.programs.teamspeak3.enable = lib.mkEnableOption "Teamspeak 3 client" // {
    default = config.isDesktop;
  };

  config = lib.mkIf config.programs.teamspeak3.enable {
    environment.systemPackages = [ pkgs-stable.teamspeak3 ];
    impermanence.normalUsers.directories = [ ".ts3client" ];
    nixpkgs.config.permittedInsecurePackages = [ "openssl-1.1.1w" ];
  };
}

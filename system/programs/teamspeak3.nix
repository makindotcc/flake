{
  pkgs,
  pkgs-stable,
  lib,
  config,
  ...
}:
{
  options.programs.teamspeak3.enable = lib.mkEnableOption "Teamspeak 3 client" // {
    default = false;
  };

  config = lib.mkIf config.programs.teamspeak3.enable ({
    nixpkgs.overlays = [
      (final: prev: {
        teamspeak3-insecure = pkgs-stable.teamspeak3;
      })
    ];

    environment.systemPackages = [ pkgs.teamspeak3-insecure ];
    impermanence.normalUsers.directories = [ ".ts3client" ];
    nixpkgs.config.permittedInsecurePackages = [ "openssl-1.1.1w" ];
  });
}

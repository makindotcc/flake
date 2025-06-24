{
  config,
  ...
}:
{
  users.users.user = {
    isNormalUser = true;
    description = "user";
    initialHashedPassword = "$6$/rMdMUxRofBZcRSd$l3tgJW4YzOrPMH0Dh/Xey4XSn7uowz9PEAJDpEmO6uUv6z5xbEL/sf1CS93VvZLCxXL5CZFW6tQ3Sr5XCIEpA.";
    extraGroups =
      [
        "networkmanager"
        "wheel"
      ]
      ++ (
        if config.virtualisation.docker.enable && config.virtualisation.docker.rootless.enable then
          [ "docker" ]
        else
          [ ]
      );
  };
  home-manager.users = {
    user = import ./home.nix;
  };
}

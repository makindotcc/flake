{
  config,
  ...
}:
{
  users.users.user = {
    isNormalUser = true;
    description = "user";
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

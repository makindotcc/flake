{
  config,
  ...
}:
{
  users.mutableUsers = false;
  users.users.user = {
    isNormalUser = true;
    description = "user";
    hashedPasswordFile = config.age.secrets.user-password.path;
    extraGroups = [
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

  age.secrets.user-password.file = ../../secrets/user-password.age;
}

{
  ...
}:
{
  users.users.user = {
    isNormalUser = true;
    description = "user";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
  };
  home-manager.users = {
    user = import ./home.nix;
  };
}

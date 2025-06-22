{
  config,
  ...
}:
{
  users.users.makin = {
    isNormalUser = true;
    description = "makin";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];

    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIL3BdWxBIA3tyMEF7xiuFQLB85iGHWlROSXNVomxBJ96 user@pc-nixos"
    ];
  };
  home-manager.users.makin = { };
}

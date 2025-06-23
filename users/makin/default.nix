{
  config,
  ...
}:
let
  keys = import ../../keys.nix;
in
{
  users.users.makin = {
    isNormalUser = true;
    description = "makin";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];

    openssh.authorizedKeys.keys = keys.pc;
  };
  home-manager.users.makin = { };
}

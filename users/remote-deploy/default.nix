# user for --target-host deployment
_:
let
  keys = import ../../keys.nix;
in
{
  users.users.remote-deploy = {
    isNormalUser = true;
    description = "deploy user";
    extraGroups = [
      "wheel"
    ];
    openssh.authorizedKeys.keys = keys.pc;
  };
  home-manager.users.remote-deploy = { };

  nix.settings.trusted-users = [ "remote-deploy" ];
}

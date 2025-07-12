{
  inputs,
  lib,
  config,
  ...
}:
{
  imports = [
    inputs.impermanence.nixosModules.impermanence
  ];

  options = {
    impermanence = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
      };
      dir = lib.mkOption {
        type = lib.types.str;
        default = "/persistent";
      };
      normalUsers.directories = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        description = "directories and files to persist for normal users";
        default = [
        ];
      };
    };
  };

  config = {
    environment.persistence.${config.impermanence.dir} = {
      enable = config.impermanence.enable;
      # todo add dirs to all users (config.users.users infinite recursion issue)
      users.user = config.impermanence.normalUsers;
    };
  };
}

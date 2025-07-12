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
    environment.persistence = {
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
    environment.persistence.${config.environment.persistence.dir} = {
      enable = config.environment.persistence.enable;
      # todo add dirs to all users (config.users.users infinite recursion issue)
      users.user = config.environment.persistence.normalUsers;
    };
  };
}

final: _:
# let
#   users = import ../users/default.nix;
# in
{
  withEnvPath = path: {
    programs.nushell.extraEnv = ''
      $env.PATH ++= [ "${path}" ];
    '';
    home.sessionPath = [ "${path}" ];
  };

  mkEnableDefaultOption =
    default: description:
    final.mkOption {
      type = final.types.bool;
      default = default;
      description = description;
    };

  # mkPersistence =
  #   xd: persistence:
  #   builtins.trace "mkPersistence:" {
  #     environment.persistence."/persistent" = builtins.trace "persistent trace" (
  #       persistence
  #       // {
  #         users =
  #           users.names
  #           |> map (name: builtins.trace "Users names: ${name}" name)
  #           |> builtins.filter (name: builtins.elem name xd)
  #           |> map (name: {
  #             name = name;
  #             value = builtins.trace "Tracing user: ${name}" (persistence.users name);
  #           })
  #           |> builtins.listToAttrs;
  #       }
  #     );
  #   };
  # mapKeysToAttr =
  #   valueBuilder: list:
  #   builtins.attrNames list
  #   |> map (name: {
  #     name = name;
  #     value = valueBuilder name;
  #   })
  #   |> builtins.listToAttrs;
}

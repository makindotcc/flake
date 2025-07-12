final: _: {
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

  collectNix =
    path:
    let
      dir = builtins.readDir path;
    in
    dir
    |> builtins.attrNames
    |> builtins.filter (f: dir.${f} == "regular")
    |> builtins.filter (f: (final.strings.hasSuffix ".nix" f))
    |> builtins.map (f: path + "/${f}");

  # Author:
  # https://github.com/RGBCube/ncc/blob/cbd9d5c906cf3bd3873989661b67301523f9c1af/lib/option.nix#L4-L7
  mkConst =
    value:
    final.mkOption {
      default = value;
      readOnly = true;
    };
}

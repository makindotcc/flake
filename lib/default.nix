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
}

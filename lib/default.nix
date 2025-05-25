_: {
  withEnvPath = path: {
    programs.nushell.extraEnv = ''
      $env.PATH ++= [ "${path}" ];
    '';
    home.sessionPath = [ "${path}" ];
  };
}

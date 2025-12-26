{
  self,
  config,
  lib,
  pkgs,
  ...
}:
{
  environment.systemPackages = [ pkgs.restic ];

  services.restic.backups.backupbox = {
    repository = "sftp://backupbox/pc";
    passwordFile = config.age.secrets.pc-restic.path;

    paths =
      let
        globalFiles =
          (
            config.environment.persistence.${config.impermanence.dir}.directories
            |> builtins.map (entry: if builtins.isAttrs entry then entry.dirPath else entry)
          )
          ++ (
            config.environment.persistence.${config.impermanence.dir}.files
            |> builtins.map (entry: if builtins.isAttrs entry then entry.filePath else entry)
          );
        homeDirsFiles =
          (config.impermanence.normalUsers.directories ++ config.impermanence.normalUsers.files)
          |> builtins.map (entry: if builtins.isAttrs entry then entry.path else entry)
          |> builtins.map (path: "${config.users.users.user.home}/${path}");
      in
      lib.unique (globalFiles ++ homeDirsFiles ++ [ "/root/.ssh/config" ]);

    exclude = [
      "/nix"
    ]
    ++ (
      [
        ".cache"
        "Android"
        "go"
        "Documents/bdev"
        "Documents/dev/*/target" # rust build artifacts
        ".local/share/Steam"
        ".local/share/docker"
        "vmware/"
      ]
      |> builtins.map (dir: "${config.users.users.user.home}/${dir}")
    );

    pruneOpts = [
      "--keep-daily 7"
      "--keep-weekly 5"
      "--keep-monthly 12"
      "--keep-yearly 20"
    ];

    timerConfig = {
      OnCalendar = "02:15";
      Persistent = true;
    };
  };

  age.secrets.pc-restic.file = self + /secrets/pc-restic.age;
}

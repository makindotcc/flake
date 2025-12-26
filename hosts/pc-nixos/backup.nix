{
  self,
  config,
  lib,
  pkgs,
  ...
}:
let
  notifySend =
    args:
    "${pkgs.su}/bin/su -s /bin/sh user -c 'export DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus; ${pkgs.libnotify}/bin/notify-send ${args}'";
in
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
      lib.unique (globalFiles ++ homeDirsFiles);

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

    extraBackupArgs = [
      "--verbose"
    ];

    backupPrepareCommand = ''
      ${notifySend ''-u normal -i drive-harddisk "Restic Backup" "Rozpoczynam backup do backupbox..."''}
    '';

    backupCleanupCommand = ''
      if [ $EXIT_STATUS -eq 0 ]; then
        ${notifySend ''-u normal -i emblem-success "Restic Backup" "Backup zakończony pomyślnie!"''}
      else
        ${notifySend ''-u critical -i dialog-error "Restic Backup" "Backup zakończony błędem (kod: $EXIT_STATUS)"''}
      fi
    '';
  };

  age.secrets.pc-restic.file = self + /secrets/pc-restic.age;
}

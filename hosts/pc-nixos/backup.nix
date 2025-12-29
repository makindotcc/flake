# todo: move off root user
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

  services.restic.backups.fs = {
    repository = "sftp://backupbox/restic/pc";
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
      ${notifySend ''-u low -i drive-harddisk "Restic Backup" "Rozpoczynam backup do backupbox..."''}
    '';

    backupCleanupCommand = ''
      if [ $EXIT_STATUS -eq 0 ]; then
        ${notifySend ''-u normal -i emblem-success "Restic Backup" "Backup zakończony pomyślnie!"''}
      else
        ${notifySend ''-u critical -i dialog-error "Restic Backup" "Backup zakończony błędem (kod: $EXIT_STATUS)"''}
      fi
    '';
  };

  systemd.services.restic-prune-all = {
    description = "Prune old restic backups";

    serviceConfig = {
      Type = "oneshot";
      User = "root";
    };

    script =
      let
        pruneOldMakinxBackups = repo: ''
          echo "Pruning old backups for repository: ${repo}"

          ${pkgs.restic}/bin/restic \
              -r sftp://backupbox/restic/makinx/${repo} \
              --password-file "${config.age.secrets.makinx-restic.path}" \
              forget --prune --keep-within 7d --keep-daily 30 --keep-weekly 12 --keep-monthly 24 \
              && REPO_STATUS_${lib.toUpper repo}=0 \
              || REPO_STATUS_${lib.toUpper repo}=$? 
        '';
      in
      ''
        ${notifySend ''-u low -i user-trash "makinx backup" "Usuwanie starych backupów..."''}

        ${
          builtins.map pruneOldMakinxBackups [
            "fs"
            "pg"
            "garage"
          ]
          |> builtins.concatStringsSep "\n"
        }

        OVERALL_STATUS=0
        for repo in fs pg garage; do
          var_name="REPO_STATUS_$(echo $repo | tr '[:lower:]' '[:upper:]')"
          eval "status=\$$var_name"
          if [ "''${status:-0}" -ne 0 ]; then
            OVERALL_STATUS="$status"
            break
          fi
        done

        if [ $OVERALL_STATUS -eq 0 ]; then
          ${notifySend ''
            -u low -i user-trash "makinx backup" \
            "Usuwanie starych backupów zakończone pomyślnie!"''}
        else
          echo "Pruning failed with exit code $OVERALL_STATUS"
          ${notifySend ''
            -u critical -i dialog-error "makinx backup" \
            "Usuwanie starych backupów zakończone błędem (kod: $OVERALL_STATUS)"''}
          exit $OVERALL_STATUS
        fi
      '';
  };

  systemd.timers.restic-prune-all = {
    description = "Timer for pruning old restic backups";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "weekly";
      Persistent = true;
    };
  };

  age.secrets = {
    pc-restic.file = self + /secrets/pc-restic.age;
    makinx-restic.file = self + /secrets/makinx-restic.age;
  };
}

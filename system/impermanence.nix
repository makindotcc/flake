{
  inputs,
  lib,
  config,
  pkgs,
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
      normalUsers =
        let
          pathConfig = lib.types.submodule {
            options = {
              name = lib.mkOption {
                type = lib.types.str;
                description = "unique name";
              };
              path = lib.mkOption {
                type = lib.types.str;
                description = "path";
              };
              mode = lib.mkOption {
                type = lib.types.enum [
                  "standard"
                  "copy"
                ];
                default = "standard";
                description = "Persistence mode";
              };
            };
          };
          pathList = lib.types.listOf (lib.types.either lib.types.str pathConfig);
        in
        {
          directories = lib.mkOption {
            type = pathList;
            description = "directories to persist for normal users";
            default = [ ];
          };
          files = lib.mkOption {
            type = pathList;
            description = "files to persist for normal users";
            default = [ ];
          };
        };
    };
  };

  config =
    let
      # author: @arminfro
      # https://github.com/nix-community/impermanence/issues/147#issuecomment-3078517729
      mkImperativePersistService =
        {
          name,
          path,
          isDir ? false,
        }:
        {
          name = "imperative-persist-${name}";
          value = {
            description = "Persist ${name} folder/file";
            wantedBy = [ "default.target" ];
            serviceConfig =
              let
                retrieveName = "${name}-retrieve";
                migrateName = "${name}-migrate";
                persist = config.impermanence.dir;
                fileRef = if isDir then "/." else "";

                pipefail = # bash
                  ''
                    set -euo pipefail
                  '';
                createPersistPathIfNotExists =
                  if isDir then # bash
                    ''
                      if [[ ! -e "${persist}${path}" ]]; then
                        ${pkgs.coreutils}/bin/mkdir -p "${persist}${path}"
                        echo "Creating directory '${persist}${path}'"
                      fi
                    ''
                  else
                    "";
                copyFromPersistToHome = # bash
                  ''
                    if [[ -e "${persist}${path}" ]]; then
                      echo "rsync -a \"${persist}${path}${fileRef}\" \"${path}\""
                      ${pkgs.rsync}/bin/rsync -a "${persist}${path}${fileRef}" "${path}"
                    else
                      echo "Path '${persist}${path}' not found while copying from persist to home"
                    fi
                  '';
                copyFromHomeToPersist = # bash
                  ''
                    if [[ -e "${path}" ]]; then
                      echo "rsync -a --delete \"${path}${fileRef}\" \"${persist}${path}\""
                      ${pkgs.rsync}/bin/rsync -a --delete "${path}${fileRef}" "${persist}${path}"
                    else
                      echo "Path '${path}' not found while copying from home to persist"
                    fi
                  '';
              in
              {
                Type = "oneshot";
                RemainAfterExit = true;
                StandardOutput = "journal";
                ExecStart =
                  (pkgs.writeShellScriptBin retrieveName ''
                    ${pipefail}
                    ${createPersistPathIfNotExists}
                    ${copyFromPersistToHome}
                  '')
                  + "/bin/${retrieveName}";

                ExecStop =
                  (pkgs.writeShellScriptBin migrateName ''
                    ${pipefail}
                    ${copyFromHomeToPersist}
                  '')
                  + "/bin/${migrateName}";
              };
          };
        };
    in
    {
      environment.persistence.${config.impermanence.dir} = {
        enable = config.impermanence.enable;
        # todo add dirs to all users (config.users.users infinite recursion issue)
        # same for systemd.user.services...
        users.user =
          let
            getStandardConfigs =
              entries:
              entries
              |> builtins.filter (entry: if builtins.isAttrs entry then entry.mode == "standard" else true)
              |> builtins.map (entry: if builtins.isAttrs entry then entry.path else entry);
          in
          {
            directories = config.impermanence.normalUsers.directories |> getStandardConfigs;
            files = config.impermanence.normalUsers.files |> getStandardConfigs;
          };
      };

      # todo apply this to all users...
      systemd.user.services = builtins.listToAttrs (
        (
          config.impermanence.normalUsers.directories
          |> builtins.filter builtins.isAttrs
          |> builtins.filter (conf: conf.mode == "copy")
          |> builtins.map (
            dir:
            mkImperativePersistService {
              name = dir.name;
              path = "/home/user/${dir.path}";
              isDir = true;
            }
          )
        )
        ++ (
          config.impermanence.normalUsers.files
          |> builtins.filter builtins.isAttrs
          |> builtins.filter (conf: conf.mode == "copy")
          |> builtins.map (
            file:
            mkImperativePersistService {
              name = file.name;
              path = "/home/user/${file.path}";
              isDir = false;
            }
          )
        )
      );
    };
}

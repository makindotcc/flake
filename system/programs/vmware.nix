{
  config,
  lib,
  pkgs,
  pkgs-stable,
  ...
}:
let
  setxkbmap = lib.getExe pkgs.setxkbmap;
  bash = lib.getExe pkgs.bash;

  # Wrapper script that clears XKB options before launch and restores after
  wrapperScript = ''
    #!${bash}
    CURRENT_XKB=$(${setxkbmap} -query 2>/dev/null | grep options | awk '{print $2}')
    ${setxkbmap} -option ""
    "$0"-unwrapped "$@"
    EXIT_CODE=$?
    [ -n "$CURRENT_XKB" ] && ${setxkbmap} -option "$CURRENT_XKB"
    exit $EXIT_CODE
  '';

  vmwareWrapped = pkgs-stable.vmware-workstation.overrideAttrs (old: {
    postFixup = (old.postFixup or "") + ''
      for bin in $out/bin/{vmware,vmware-tray,vmplayer,vmware-netcfg}; do
        [ -f "$bin" ] || continue
        mv "$bin" "$bin-unwrapped"
        echo ${lib.escapeShellArg wrapperScript} > "$bin"
        chmod +x "$bin"
      done
    '';
  });
in
{
  options.programs.vmware.enable = lib.mkEnableOption "Enable VMware support" // {
    default = config.isPersonalPuter;
  };

  config = lib.mkIf config.programs.vmware.enable {
    virtualisation.vmware.host = {
      enable = true;
      package = vmwareWrapped;
    };
    impermanence.normalUsers.directories = [ "vmware" ];
    environment.persistence.${config.impermanence.dir}.directories = [
      "/etc/vmware"
    ];
  };
}

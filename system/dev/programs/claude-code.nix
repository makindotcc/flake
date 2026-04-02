{
  lib,
  config,
  pkgs-stable,
  ...
}:
{
  options.dev.programs.claude-code = {
    enable = lib.mkEnableDefaultOption config.dev.programs.all "Enable Claude Code IDE" // {
      default = config.isPersonalPuter;
    };
  };

  config = lib.mkIf config.dev.programs.claude-code.enable {
    environment.systemPackages = [
      pkgs-stable.claude-code
    ]
    ++ (lib.optionals (config.isLinux && config.isDesktop) [
      (pkgs-stable.writeShellScriptBin "send-claude-attention" ''
        ${pkgs-stable.libnotify}/bin/notify-send "Claude Code" "Attention required"
        # ${pkgs-stable.pipewire}/bin/pw-play /run/current-system/sw/share/sounds/ocean/stereo/bell.oga --volume=1.2
      '')
    ]);
    impermanence.normalUsers = {
      directories = [
        ".claude"
      ];
      files = [
        {
          name = "claudejson";
          path = ".claude.json";
          mode = "copy";
        }
      ];
    };
    environment.persistence.${config.impermanence.dir}.directories = [
      "/etc/claude-code"
    ];
  };
}

{
  lib,
  config,
  pkgs,
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
      pkgs.claude-code
    ]
    ++ (lib.optionals (config.isLinux && config.isDesktop) [
      (pkgs.writeShellScriptBin "send-claude-attention" ''
        ${pkgs.libnotify}/bin/notify-send "Claude Code" "Attention required"
        ${pkgs.pipewire}/bin/pw-play /run/current-system/sw/share/sounds/ocean/stereo/bell.oga --volume=1.2
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

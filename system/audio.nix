{ lib, config, ... }:
lib.mkIf config.isDesktop {
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };
  impermanence.normalUsers.directories = [
    ".local/state/wireplumber"
  ];
}

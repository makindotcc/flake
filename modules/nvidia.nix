{ config, pkgs, ... }:
{
  hardware.enableRedistributableFirmware = true;

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = true;
    powerManagement.finegrained = false;
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.latest;
  };

  # BRAWO KURWA BRAWO UKRYTE MENU BY NAPRAWIC SLEEPA
  systemd.services.systemd-suspend.environment.SYSTEMD_SLEEP_FREEZE_USER_SESSIONS = "false";

  hardware.graphics = {
    enable = true;
    enable32Bit = true;

    extraPackages = with pkgs; [
      vaapiVdpau
      libvdpau
      libvdpau-va-gl
      nvidia-vaapi-driver
    ];
  };

  boot.kernelParams = [
    "module_blacklist=amdgpu"
    "nvidia.NVreg_EnableGpuFirmware=0"
  ];

  services.xserver = {
    videoDrivers = [ "nvidia" ];

    screenSection = ''
      Option         "metamodes" "nvidia-auto-select +0+0 {ForceFullCompositionPipeline=On}"
      Option         "AllowIndirectGLXProtocol" "off"
      Option         "TripleBuffer" "on"
    '';
  };
}

# testy (kernel 6.12.8):
# 565.77:
#  - powerManagement.enable = true; open = true; == po win + L miga minitor na kazdy kolor
#  - powerManagement.enable = false; open = true; == NIE MA TAPETY NIE MA IKONEK NIE MA NICZEGO ?
#  - powerManagement.enable = false; open = false; == NIE MA TAPETY NIE MA IKONEK NIE MA NICZEGO ?
#  - powerManagement.enable = true; open = false; == odpala sie do verbose po suspendzie
# 550.142:
#  - powerManagement.enable = false; open = false; == NIE MA TAPETY NIE MA IKONEK NIE MA NICZEGO ?
#  - powerManagement.enable = true; open = false; == odpala sie do verbose po suspendzie
#  - powerManagement.enable = true; open = true; == wgl nie ma obrazu i essa
#  - powerManagement.enable = false; open = true; == NIE MA TAPETY NIE MA IKONEK NIE MA NICZEGO ?
# 565.77 + NVreg_PreserveVideoMemoryAllocations=1:
#  - powerManagement.enable = false; open = true; == NIE MA TAPETY NIE MA IKONEK NIE MA NICZEGO ?

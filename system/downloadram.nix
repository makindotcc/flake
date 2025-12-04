{ ... }:
{
  zramSwap = {
    enable = true;
    memoryPercent = 250;
  };

  boot.kernel.sysctl = {
    "vm.dirty_background_bytes" = 134217728;
    "vm.dirty_bytes" = 268435456;
    "vm.page-cluster" = 0;
    "vm.swappiness" = 180;
    "vm.watermark_boost_factor" = 0;
    "vm.watermark_scale_factor" = 125;
  };
}

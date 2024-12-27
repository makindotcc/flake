{
  pkgs,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    lunar-client
    (prismlauncher.override {
      jdks = [
        jdk8
        jdk21
      ];
    })
  ];

  programs.steam = {
    enable = true;
    extest.enable = true;
    protontricks.enable = true;
  }
}

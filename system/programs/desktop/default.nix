{
  lib,
  pkgs,
  pkgs-stable,
  config,
  ...
}:
{
  imports = lib.collectNix ./. |> lib.remove ./default.nix;
  environment.systemPackages =
    [
      pkgs.eyedropper
      pkgs.krita
    ]
    ++ (lib.optional config.isPhysical pkgs.gparted)
    ++ (lib.optionals config.isLinux [
      pkgs.fsearch
      pkgs.adw-gtk3
      pkgs.amberol
      pkgs.mission-center
      pkgs-stable.clapper
    ]);
}

{
  inputs,
  pkgs,
  lib,
  config,
  ...
}:
lib.mkIf config.isDesktop {
  fonts = {
    enableDefaultPackages = true;
    packages = [
      inputs.apple-fonts.packages.${pkgs.system}.sf-pro-nerd
      inputs.apple-fonts.packages.${pkgs.system}.sf-mono-nerd
      inputs.apple-fonts.packages.${pkgs.system}.ny-nerd
      inputs.apple-emoji-linux.packages.${pkgs.system}.apple-emoji-linux
      pkgs.comic-mono
    ];

    fontconfig = {
      enable = true;
      defaultFonts = {
        sansSerif = [
          "SFRounded Nerd Font"
        ];
        serif = [
          "SFRounded Nerd Font"
        ];
        monospace = [ "SFMono Nerd Font" ];
        emoji = [ "Apple Color Emoji" ];
      };
      useEmbeddedBitmaps = true;
    };
  };
}

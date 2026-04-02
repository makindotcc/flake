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
      inputs.apple-fonts.packages.${pkgs.stdenv.hostPlatform.system}.sf-pro-nerd
      inputs.apple-fonts.packages.${pkgs.stdenv.hostPlatform.system}.sf-mono-nerd
      inputs.apple-fonts.packages.${pkgs.stdenv.hostPlatform.system}.ny-nerd
      inputs.apple-emoji-linux.packages.${pkgs.stdenv.hostPlatform.system}.apple-emoji-linux
      pkgs.comic-mono
      pkgs.noto-fonts-cjk-sans
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

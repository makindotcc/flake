{
  pkgs,
  lib,
  config,
  ...
}:
{
  options.programs.helium.enable = lib.mkEnableOption "Helium browser" // {
    default = config.isDesktop;
  };
  config = lib.mkIf config.programs.helium.enable (
    let
      helium = pkgs.appimageTools.wrapType2 rec {
        pname = "helium";
        version = "0.10.2.1";

        src = pkgs.fetchurl {
          url = "https://github.com/imputnet/helium-linux/releases/download/${version}/${pname}-${version}-x86_64.AppImage";
          hash = "sha256-Kh6UgdleK+L+G4LNiQL2DkQIwS43cyzX+Jo6K0/fX1M=";
        };

        extraPkgs =
          pkgs: with pkgs; [
            libva
          ];

        extraInstallCommands =
          let
            contents = pkgs.appimageTools.extractType2 { inherit pname version src; };
          in
          ''
            install -m 444 -D ${contents}/${pname}.desktop -t $out/share/applications
            substituteInPlace $out/share/applications/${pname}.desktop \
              --replace 'Exec=AppRun' 'Exec=${pname}'
            install -m 444 -D ${contents}/${pname}.png -t $out/share/pixmaps
          '';
      };
    in
    {
      environment.systemPackages = [ helium ];
      impermanence.normalUsers.directories = [ ".config/net.imput.helium" ];

      # symlink widevine from chrome to helium
      systemd.tmpfiles.rules = lib.mkIf config.programs.chrome.enable (
        let
          home = config.users.users.user.home;
        in
        [
          "L+ ${home}/.config/net.imput.helium/WidevineCdm - - - - ${home}/.config/google-chrome/WidevineCdm"
        ]
      );

      # allow usb access for helium (e.g. usevia.app)
      services.udev.extraRules = ''
        KERNEL=="hidraw*", SUBSYSTEM=="hidraw", MODE="0666", TAG+="uaccess", TAG+="udev-acl"
      '';
    }
  );
}

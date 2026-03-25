{
  config,
  lib,
  pkgs,
  ...
}:
{
  config = lib.mkIf config.dev.programs.re.binaryninja.enable {
    environment.systemPackages =
      let
        binaryninja-src = pkgs.requireFile {
          name = "binaryninja_linux_stable_personal.zip";
          sha256 = "1j27wqr18cg6q0m45c4xa18fr1y3j00mh7601cgvdl83lnaws9rm";
          message = ''
            Binary Ninja is not in the nix store. Add it with:
              nix-store --add-fixed sha256 binaryninja_linux_stable_personal.zip
          '';
        };

        binaryninja-unwrapped = pkgs.stdenvNoCC.mkDerivation {
          pname = "binaryninja-unwrapped";
          version = "personal";
          src = binaryninja-src;
          nativeBuildInputs = [ pkgs.unzip ];
          unpackPhase = "unzip $src";
          installPhase = ''
            mkdir -p $out/opt
            cp -r binaryninja $out/opt/binaryninja
          '';
        };

        binaryninja = pkgs.buildFHSEnv {
          name = "binaryninja";
          targetPkgs = p: with p; [
            dbus
            fontconfig
            freetype
            libGL
            libxkbcommon
            libx11
            libxcb
            libxcb-cursor
            libxcb-image
            libxcb-keysyms
            libxcb-render-util
            libxcb-wm
            wayland
            zlib
          ];
          runScript = pkgs.writeScript "binaryninja.sh" ''
            exec ${binaryninja-unwrapped}/opt/binaryninja/binaryninja "$@"
          '';
          extraInstallCommands = ''
            mkdir -p $out/share/applications $out/share/icons/hicolor/256x256/apps
            cp ${binaryninja-unwrapped}/opt/binaryninja/docs/img/logo.png $out/share/icons/hicolor/256x256/apps/binaryninja.png
            cat > $out/share/applications/binaryninja.desktop <<EOF
            [Desktop Entry]
            Name=Binary Ninja
            Exec=$out/bin/binaryninja %u
            Icon=binaryninja
            Type=Application
            Categories=Development;Debugger;
            MimeType=application/x-executable;application/x-elf;
            EOF
          '';
          meta.description = "Binary Ninja";
        };
      in
      [ binaryninja ];
  };
}

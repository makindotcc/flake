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

        binaryninja-mcp = pkgs.writeShellScriptBin "binaryninja-mcp" ''
          exec ${
            pkgs.python3.withPackages (
              ps: with ps; [
                anthropic
                mcp
                requests
              ]
            )
          }/bin/python3 "$@"
        '';

        binaryninja = pkgs.buildFHSEnv {
          name = "binaryninja";
          targetPkgs =
            p: with p; [
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
              (python3.withPackages (ps: [ ps.pip ]))
              wayland
              zlib
            ];
          runScript = pkgs.writeScript "binaryninja.sh" ''
            BNDIR="$HOME/.local/share/binaryninja"
            STAMP="$BNDIR/.nix-store-path"

            if [ ! -f "$STAMP" ] || [ "$(cat "$STAMP")" != "${binaryninja-src}" ]; then
              rm -rf "$BNDIR"
              mkdir -p "$BNDIR"
              cp -r ${binaryninja-unwrapped}/opt/binaryninja/. "$BNDIR"
              chmod -R u+w "$BNDIR"
              echo "${binaryninja-src}" > "$STAMP"
            fi

            BNCONFIG="$HOME/.binaryninja"
            mkdir -p "$BNCONFIG"
            if [ ! -f "$BNCONFIG/settings.json" ]; then
              echo '{"python.interpreter": "/usr/lib/libpython3.13.so"}' > "$BNCONFIG/settings.json"
            elif ! grep -q "python.interpreter" "$BNCONFIG/settings.json"; then
              sed -i 's/^{/{\"python.interpreter\": \"\/usr\/lib\/libpython3.13.so\", /' "$BNCONFIG/settings.json"
            fi

            exec "$BNDIR/binaryninja" "$@"
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
      [
        binaryninja
        binaryninja-mcp
      ];

    impermanence.normalUsers.directories = [
      ".binaryninja"
      ".local/share/binaryninja"
    ];
  };
}

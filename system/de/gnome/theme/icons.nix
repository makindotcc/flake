{ pkgs, self, ... }:
{
  gtk = {
    enable = true;
    iconTheme = {
      name = "retroicons";
      package = (
        # proprietary icons
        # https://x.com/EmilPixel/status/1943361135861707245
        pkgs.stdenv.mkDerivation {
          name = "retroicons";
          src = self + /secrets/retroicons;

          nativeBuildInputs = [ pkgs.gtk3 ];

          installPhase = ''
            runHook preInstall

            mkdir -p $out/share/icons/retroicons
            cp -r $src/* $out/share/icons/retroicons/
            gtk-update-icon-cache $out/share/icons/retroicons

            runHook postInstall
          '';
        }
      );
    };
  };
}

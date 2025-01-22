{
  description = "Kobweb cli";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs =
    { self, nixpkgs }:
    let
      pkgs = import nixpkgs { system = "x86_64-linux"; };
    in
    {
      packages.default = pkgs.stdenv.mkDerivation {
        pname = "kobweb";
        version = "0.9.18";

        src = pkgs.fetchurl {
          url = "https://github.com/varabyte/kobweb-cli/releases/download/v0.9.18/kobweb-0.9.18.zip";
          sha256 = "sha256-DWJbuVaw4x2PA0+V3F6qRetXvVlFu0xtByUvK9hByew=";
        };

        nativeBuildInputs = [
          pkgs.unzip
          pkgs.playwright-driver
        ];
        buildPhase = ''
          unzip $src
        '';

        installPhase = ''
          mkdir -p $out/bin
          mkdir -p $out/lib
          cp -r bin/* $out/bin/
          cp -r lib/* $out/lib/
        '';

        meta = with pkgs.lib; {
          description = "Kobweb CLI for managing Kobweb projects";
          homepage = "https://github.com/varabyte/kobweb-cli";
        };
      };
    };
}

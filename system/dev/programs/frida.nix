{
  config,
  lib,
  pkgs,
  ...
}:
{
  config = lib.mkIf config.dev.programs.re.frida.enable {
    nixpkgs.overlays = [
      (final: prev: {
        python3Packages = prev.python3Packages.overrideScope (
          pyFinal: pyPrev: {
            frida-python = pyPrev.frida-python.overridePythonAttrs (old: rec {
              version = "17.8.3";
              src = prev.fetchPypi {
                pname = "frida";
                inherit version;
                format = "wheel";
                hash = "sha256-xggey29kj6EBU7vBrU3SjmXcm1zTEzfxMxSMa8/PBw0=";
                platform = "manylinux1_x86_64";
                abi = "abi3";
                python = "cp37";
                dist = "cp37";
              };
            });
          }
        );

        frida-tools = prev.frida-tools.overridePythonAttrs (old: rec {
          version = "14.7.0";
          src = prev.fetchPypi {
            inherit version;
            pname = "frida_tools";
            hash = "sha256-KrlydiTOA+/cztzY78uU3NS/dGD4m6cTNuw1AsHLUSU=";
          };
          dependencies =
            old.dependencies or [ ]
            |> map (dep: if dep.pname or "" == "frida-python" then final.python3Packages.frida-python else dep);
        });
      })
    ];

    environment.systemPackages = [ pkgs.frida-tools ];
  };
}

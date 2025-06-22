{
  pkgs,
  lib,
  config,
  ...
}:
{
  options.dev.langs.rust = {
    enable = lib.mkEnableOption "Rust programming language support";
  };

  config = lib.mkIf (config.dev.langs.rust.enable) {
    environment.systemPackages =
      with pkgs;
      [
        rustc
        rustup
        cargo

        pkg-config
        openssl
      ]
      ++ lib.optionals config.dev.programs.editor.vscode.enable [
        clippy
        rustfmt
        rust-analyzer
      ];

    environment.sessionVariables = {
      RUST_SRC_PATH = pkgs.rust.packages.stable.rustPlatform.rustLibSrc;
      PKG_CONFIG_PATH = "${pkgs.openssl.dev}/lib/pkgconfig";
    };

    home-manager.sharedModules = [
      (lib.withEnvPath "~/.cargo/bin")
    ];
  };
}

{
  inputs,
  pkgs,
  ...
}:
{
  environment.systemPackages = (
    with pkgs;
    [
      nixfmt-rfc-style

      rustc
      cargo
      clippy
      rustfmt
      rust-analyzer

      gleam
      go
      jdk
      nodejs_24
      gdb
      glib
      gnumake
      dconf2nix

      erlang
      rebar3

      gccgo

      pkg-config
      openssl
    ]
  );

  environment.sessionVariables = {
    PKG_CONFIG_PATH = "${pkgs.openssl.dev}/lib/pkgconfig";
    RUST_SRC_PATH = pkgs.rust.packages.stable.rustPlatform.rustLibSrc;
  };

  # dziala to wgl ?
  home-manager.sharedModules = [
    {
      home.sessionPath = [ "$HOME/.cargo/bin" ];
    }
  ];
}

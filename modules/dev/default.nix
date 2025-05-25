{
  inputs,
  pkgs,
  lib,
  ...
}:
{
  imports = [
    ./localcerts.nix
  ];

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
      lldb
      glib
      gnumake
      dconf2nix
      lld

      erlang
      rebar3

      gccgo

      pkg-config
      openssl

      # hakowanie na ekranie
      burpsuite
      ida-free
      # binja https://gist.github.com/Ninja3047/256a0727e7ea09ab6c82756f11265ee1
      frida-tools
      # jadx
      vscode
      jetbrains.idea-community-bin

      inotify-tools
    ]
  );

  environment.sessionVariables = {
    PKG_CONFIG_PATH = "${pkgs.openssl.dev}/lib/pkgconfig";
    RUST_SRC_PATH = pkgs.rust.packages.stable.rustPlatform.rustLibSrc;
  };

  home-manager.sharedModules = [
    (lib.withEnvPath "~/.cargo/bin")
    ./home.nix
  ];
}

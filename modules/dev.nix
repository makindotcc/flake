{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    nixpkgs-fmt
    cargo
    gleam
    go
    jdk
    nodejs_23
  ];
}

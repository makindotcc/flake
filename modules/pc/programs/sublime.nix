{ pkgs, ... }:
{
  environment.systemPackages = [
    pkgs.sublime4
  ];

  nixpkgs.config.permittedInsecurePackages = [
    "openssl-1.1.1w"
  ];
}

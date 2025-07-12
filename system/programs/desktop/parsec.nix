{ pkgs, ... }:
{
  environment.systemPackages = [ pkgs.parsec-bin ];
  impermanence.normalUsers.directories = [
    ".parsec"
    ".parsec-persistent"
  ];
}

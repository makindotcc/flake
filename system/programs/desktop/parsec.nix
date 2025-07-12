{ pkgs, ... }:
{
  environment.systemPackages = [ pkgs.parsec-bin ];
  environment.persistence.normalUsers.directories = [
    ".parsec"
    ".parsec-persistent"
  ];
}

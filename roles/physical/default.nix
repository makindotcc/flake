{
  pkgs,
  inputs,
  ...
}:
{
  imports = [
    ../graphical
    ./hw
    ./programs
    ./fonts.nix
  ];
}

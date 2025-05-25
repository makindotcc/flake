{
  pkgs,
  ...
}:
{
  programs = {
    nushell = {
      shellAliases = {
        nixcfg = "code ~/.config/nix";
      };
    };
  };
}

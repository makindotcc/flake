{
  nix.gc = {
    automatic = true;
    options = "--delete-older-than 7d";
  };
  home-manager.sharedModules = [
    {
      nix.gc = {
        automatic = true;
        options = "--delete-older-than 7d";
      };
    }
  ];
}

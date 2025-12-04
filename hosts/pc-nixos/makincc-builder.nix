_: {
  home-manager.users.user = {
    programs.ssh = {
      matchBlocks = {
        "github.com-buzkaaclicker-bins" = {
          hostname = "github.com";
          identityFile = "~/.ssh/id_ed25519";
        };
        "github.com-buzkaaclicker-frontend-og" = {
          hostname = "github.com";
          identityFile = "~/.ssh/id_ed25519";
        };
      };
    };
  };
}

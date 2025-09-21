_: {
  home-manager.users.user = {
    programs.ssh = {
      matchBlocks."*" = { };
      extraConfig = ''
        Host github.com-buzkaaclicker-bins
          Hostname github.com
          IdentityFile ~/.ssh/id_ed25519

        Host github.com-buzkaaclicker-frontend-og
          Hostname github.com
          IdentityFile ~/.ssh/id_ed25519
      '';
    };
  };
}

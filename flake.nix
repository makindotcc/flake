{
  description = "moje sprzety";

  inputs = {
    self.submodules = true;
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    apple-fonts = {
      url = "github:Lyndeno/apple-fonts.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    dash-to-panel-win11 = {
      url = "github:makindotcc/dash-to-panel-win11/ricing";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    s76-scheduler-plugin = {
      url = "github:makindotcc/s76-scheduler-plugin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    apple-emoji-linux = {
      url = "github:samuelngs/apple-emoji-linux/e56448ab6b556c9a3be63ce0fb1903b70fd87b61";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    urldebloater = {
      url = "github:makindotcc/urldebloater";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    impermanence = {
      url = "github:nix-community/impermanence";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    vscode-server = {
      url = "github:nix-community/nixos-vscode-server";
      flake = false;
    };

    buzkaaclicker-backend = {
      url = "github:buzkaaclicker/backend-rs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # buzkaaclicker-backend.url = "path:/home/user/Documents/dev/buzkaaclicker/backend-rs";
    antibridge = {
      url = "git+ssh://git@github.com/makindotcc/AntiBridge";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zscrpl = {
      url = "path:./hosts/makincc/inputs/zscrpl";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    wayfire-src = {
      url = "git+https://github.com/WayfireWM/wayfire?submodules=1";
      flake = false;
    };
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      nixpkgs-stable,
      ...
    }:
    let
      additionalArgs =
        { system }:
        {
          inherit self;
          inherit inputs;

          pkgs-stable = import nixpkgs-stable {
            inherit system;
            config.allowUnfree = true;
          };

          lib = nixpkgs.lib.extend (import ./lib);
        };
    in
    {
      nixosConfigurations = {
        pc-nixos = nixpkgs.lib.nixosSystem rec {
          system = "x86_64-linux";
          specialArgs = additionalArgs { inherit system; };
          modules = [
            ./hosts/pc-nixos/configuration.nix
          ];
        };

        pc-wsl = nixpkgs.lib.nixosSystem rec {
          system = "x86_64-linux";
          specialArgs = additionalArgs { inherit system; };
          modules = [
            ./hosts/pc-wsl/configuration.nix
          ];
        };

        makincc = nixpkgs.lib.nixosSystem rec {
          system = "x86_64-linux";
          specialArgs = additionalArgs { inherit system; };
          modules = [
            ./hosts/makincc/configuration.nix
          ];
        };
      };
    };
}

{
  description = "moje sprzety";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-master.url = "github:NixOS/nixpkgs/master";
    nixos-wsl.url = "github:nix-community/NixOS-WSL/main";
    home-manager.url = "github:nix-community/home-manager/master";
    firefox-gnome-theme = {
      url = "github:rafaelmardojai/firefox-gnome-theme";
      flake = false;
    };
    apple-fonts.url = "github:Lyndeno/apple-fonts.nix";
    dash-to-panel-win11.url = "github:makindotcc/dash-to-panel-win11/flake";
    apple-emoji-linux.url = "github:samuelngs/apple-emoji-linux";
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      nixpkgs-master,
      ...
    }:
    let
      additionalArgs =
        { system }:
        {
          inherit inputs;
          pkgs-master = import nixpkgs-master {
            inherit system;
            config.allowUnfree = true;
          };
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

        vmware-nix = nixpkgs.lib.nixosSystem rec {
          system = "x86_64-linux";
          specialArgs = additionalArgs { inherit system; };
          modules = [
            ./hosts/vmware-nix/configuration.nix
          ];
        };
      };
    };
}

{
  description = "moje sprzety";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-24.11";
    nixos-wsl.url = "github:nix-community/NixOS-WSL/main";
    home-manager.url = "github:nix-community/home-manager/master";
    firefox-gnome-theme = {
      url = "github:rafaelmardojai/firefox-gnome-theme";
      flake = false;
    };
    apple-fonts.url = "github:Lyndeno/apple-fonts.nix";
    dash-to-panel-win11.url = "github:makindotcc/dash-to-panel-win11/ricing";
    apple-emoji-linux.url = "github:samuelngs/apple-emoji-linux";
    urldebloater.url = "github:makindotcc/urldebloater";
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

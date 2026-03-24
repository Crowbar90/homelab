{
  description = "Homelab NixOS configurations";

  inputs = {
    nixpkgs.url = "github:NixOs/nixpkgs/nixos-25.11";
  };

  outputs =
    { self, nixpkgs, ... }:
    let
      system = "x86_64-linux";
    in
    {
      nixosConfigurations.postgresql = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          ./modules/base.nix
          ./hosts/postgresql/configuration.nix
        ];
      };

      nixosConfigurations.k3s-cp-1 = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          ./modules/base.nix
          ./hosts/k3s-cp-1/configuration.nix
        ];
      };

      nixosConfigurations.k3s-cp-2 = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          ./modules/base.nix
          ./hosts/k3s-cp-2/configuration.nix
        ];
      };

      nixosConfigurations.k3s-cp-3 = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          ./modules/base.nix
          ./hosts/k3s-cp-3/configuration.nix
        ];
      };
    };
}

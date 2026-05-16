{
  description = "Homelab NixOS configurations";

  inputs = {
    nixpkgs.url = "github:NixOs/nixpkgs/nixos-25.11";

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  nixConfig = {
    extra-substituters = [ "https://mic92.cachix.org" ];
    extra-trusted-public-keys = [ "mic92.cachix.org-1:gi8IhgiT3CYZnJsaW7fxznzTkMUOn1RY4GmXdT/nXYQ=" ];
  };

  outputs =
    { self, nixpkgs, sops-nix, ... }@inputs:
    let
      system = "x86_64-linux";
    in
    {
      nixosConfigurations.postgresql = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs; };
        modules = [
          ./modules/base.nix
          ./hosts/postgresql/configuration.nix
        ];
      };

      nixosConfigurations.k3s-cp-1 = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs; };
        modules = [
          ./modules/base.nix
          ./hosts/k3s-cp-1/configuration.nix
          sops-nix.nixosModules.sops
        ];
      };

      nixosConfigurations.k3s-cp-2 = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs; };
        modules = [
          ./modules/base.nix
          ./hosts/k3s-cp-2/configuration.nix
          sops-nix.nixosModules.sops
        ];
      };

      nixosConfigurations.k3s-cp-3 = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs; };
        modules = [
          ./modules/base.nix
          ./hosts/k3s-cp-3/configuration.nix
          sops-nix.nixosModules.sops
        ];
      };
    };
}

{
  description = "Deterministic NixOS Proxmox Template";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
  };

  outputs = { self, nixpkgs }:
  let
    system = "x86_64-linux";
    lib = nixpkgs.lib;
  in {

    packages.${system}.qcow =
      (lib.nixosSystem {
        inherit system;

        modules = [

          # This module enables qcow image builds
          "${nixpkgs}/nixos/modules/virtualisation/qemu-vm.nix"

          ({ pkgs, ... }: {

            services.qemuGuest.enable = true;
            services.cloud-init.enable = true;
            services.openssh.enable = true;

            networking.useDHCP = true;

            boot.loader.systemd-boot.enable = true;
            boot.loader.efi.canTouchEfiVariables = true;

            boot.growPartition = true;
            fileSystems."/".autoResize = true;

            boot.kernelParams = [ "console=ttyS0" ];

            environment.systemPackages = with pkgs; [
              vim
              git
              curl
              htop
            ];

            system.stateVersion = "24.05";
          })

        ];
      }).config.system.build.qcow2;

  };
}

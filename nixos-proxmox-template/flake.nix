{
  description = "Deterministic NixOS Proxmox Template";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
  };

  outputs = { self, nixpkgs }:
  let
    system = "x86_64-linux";

    pkgs = import nixpkgs { inherit system; };

    nixosConfig = nixpkgs.lib.nixosSystem {
      inherit system;

      modules = [

        ({ config, pkgs, ... }: {

          # Basic VM config
          services.qemuGuest.enable = true;
          services.cloud-init.enable = true;

          services.openssh.enable = true;

          networking.useDHCP = true;

          # Disk expansion for Terraform resized disks
          boot.growPartition = true;
          fileSystems."/".autoResize = true;

          # Bootloader (UEFI)
          boot.loader.systemd-boot.enable = true;
          boot.loader.efi.canTouchEfiVariables = true;

          # Serial console support (nice for qm terminal)
          boot.kernelParams = [ "console=ttyS0" ];

          # Minimal but practical packages
          environment.systemPackages = with pkgs; [
            vim
            git
            curl
            htop
          ];

          # Clean template behavior
          systemd.services."reset-machine-id" = {
            wantedBy = [ "multi-user.target" ];
            serviceConfig.Type = "oneshot";
            script = ''
              truncate -s 0 /etc/machine-id
            '';
          };

          system.stateVersion = "25.11";
        })

      ];
    };

  in {

    packages.${system}.qcow =
      nixosConfig.config.system.build.qcow2;

  };
}

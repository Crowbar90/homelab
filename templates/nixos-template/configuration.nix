{ config, pkgs, lib, ... }:

{
  # The upstream proxmox-image.nix module (imported by nixos-generators
  # format = "proxmox") automatically enables:
  #   - services.cloud-init.enable = true
  #   - services.cloud-init.network.enable = true
  #   - services.qemuGuest.enable = true
  #   - networking.hostName = mkForce ""
  #   - networking.useDHCP = false
  #   - boot.growPartition, boot.loader.grub, fileSystems."/"
  #   - serial console on ttyS0
  #
  # Hardware defaults (cores, memory, disk) are left at upstream values
  # so they can be overridden per-VM when cloning.

  # Template name shown in Proxmox
  proxmox.qemuConf.name = "nixos-template";

  # Essential packages
  environment.systemPackages = with pkgs; [
    vim
    git
  ];

  # SSH access (key-only; cloud-init injects the keys)
  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
    settings.KbdInteractiveAuthentication = false;
  };

  # Passwordless sudo for wheel group
  security.sudo.wheelNeedsPassword = false;

  # Enable flakes for remote management via nixos-rebuild
  nix.settings.trusted-users = [ "root" "@wheel" ];
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  system.stateVersion = "25.11";
}

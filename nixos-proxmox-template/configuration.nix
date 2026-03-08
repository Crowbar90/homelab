{ config, pkgs, ... }:
{
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

  system.stateVersion = "25.11";
}

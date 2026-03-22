{ config, pkgs, lib, ... }:

{
  imports = [
    ../../modules/base.nix
  ];

  networking.hostName = "k3s-node1";

  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/vda";

  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    autoResize = true;
    fsType = "ext4";
  };

  system.stateVersion = "25.11";

  # Enable k3s
  services.k3s = {
    enable = true;
    role = "server";
    clusterInit = true;

    extraFlags = [
      "--disable=traefik"
      "--write-kubeconfig-mode=0644"
      "--tls-san=192.168.40.41"
    ];
  };

  # Open required ports
  networking.firewall.allowedTCPPorts = [
    6443  # Kubernetes API
  ];

  # Required for Kubernetes
  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
    "net.bridge.bridge-nf-call-iptables" = 1;
  };

  # Helpful tools
  environment.systemPackages = with pkgs; [
    kubectl
    k9s
  ];
}

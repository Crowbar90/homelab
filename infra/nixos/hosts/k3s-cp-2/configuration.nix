{ config, pkgs, lib, ... }:

{
  imports = [
    ../../modules/vm.nix
  ];

  networking.hostName = "k3s-cp-2";

  system.stateVersion = "25.11";

  # services.k3s = {
  #   enable = true;
  #   role = "server";
  #   clusterInit = true;

  #   extraFlags = [
  #     "--disable=traefik"
  #     "--write-kubeconfig-mode=0644"
  #     "--tls-san=192.168.40.41"
  #   ];
  # };

  networking.firewall.allowedTCPPorts = [
    6443  # Kubernetes API
  ];

  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
    "net.bridge.bridge-nf-call-iptables" = 1;
  };

  environment.systemPackages = with pkgs; [
    kubectl
    k9s
  ];
}

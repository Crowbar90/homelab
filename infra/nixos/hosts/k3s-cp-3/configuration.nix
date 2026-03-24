{ config, pkgs, lib, ... }:

{
  imports = [
    ../../modules/vm.nix
  ];

  networking.hostName = "k3s-cp-3";

  system.stateVersion = "25.11";

  networking = {
    interfaces.ens18.ipv4.addresses = [{
      address = "192.168.40.43";
      prefixLength = 24;
    }];

    defaultGateway = {
      address = "192.168.40.1";
      interface = "ens18";
    };

    firewall.allowedTCPPorts = [
      6443  # Kubernetes API
    ];
  };

  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
    "net.bridge.bridge-nf-call-iptables" = 1;
  };

  environment.systemPackages = with pkgs; [
    kubectl
    k9s
  ];
}

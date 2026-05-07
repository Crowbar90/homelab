{ config, pkgs, lib, inputs, ... }:

{
  imports = [
    ../../modules/vm.nix
    inputs.sops-nix.nixosModules.sops
  ];

  sops = {
    defaultSopsFile = ../../secrets.yaml;
    validateSopsFiles = false;

    age.keyFile = "/var/lib/sops-nix/key.txt";

    secrets.k3s-token = {
      owner = "root";
      group = "root";
      mode = "0400";
    };
  };

  system.stateVersion = "25.11";

  services.k3s = {
    enable = true;
    role = "server";
    tokenFile = config.sops.secrets.k3s-token.path;
    clusterInit = false;
    serverAddr = "https://192.168.40.41:6443";
    
    extraFlags = [
      "--write-kubeconfig-mode=0644"
      "--tls-san=k3s.homelab.middleearth.cc"
      "--tls-san=192.168.40.40"
      "--tls-san=192.168.40.41"
      "--tls-san=192.168.40.42"
      "--tls-san=192.168.40.43"
    ];
  };

  services.openssh.hostKeys = [
    {
      path = "/etc/ssh/ssh_host_ed25519_key";
      type = "ed25519";
    }
  ];

  networking = {
    hostName = "k3s-cp-3";
    useDHCP = false;
    nameservers = [ "192.168.40.1" ];

    interfaces.ens18.useDHCP = false;
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
      2379  # Etcd clients
      2380  # Etcd peers
    ];

    firewall.allowedUDPPorts = [
      8472  # Flannel
    ];
  };

  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
    "net.bridge.bridge-nf-call-iptables" = 1;
  };

  boot.supportedFilesystems = [ "nfs" ];
  services.rpcbind.enable = true;

  environment.systemPackages = with pkgs; [
    kubectl
    k9s
    nfs-utils
  ];
}

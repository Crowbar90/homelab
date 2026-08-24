{ config, pkgs, lib, inputs, ... }:

{
  imports = [
    inputs.sops-nix.nixosModules.sops
  ];

  sops = {
    defaultSopsFile = ../../secrets.yaml;
    validateSopsFiles = false;
    age.keyFile = "/var/lib/sops-nix/key.txt";

    secrets."cloudflare-api-token" = {
      owner = "caddy";
      group = "caddy";
      mode = "0400";
      restartUnits = [ "caddy.service" ];
    };
  };

  services.jellyfin = {
    enable = true;
    openFirewall = true;
  };

  services.caddy = {
    enable = true;
    package = pkgs.caddy.withPlugins {
      plugins = [ "github.com/caddy-dns/cloudflare@v0.2.4" ];
      hash = "";
    };
    
    virtualHosts."jellyfin.middleearth.cc".extraConfig = ''
      reverse_proxy http://localhost:8096
      
      tls {
        dns cloudflare "${config.sops.secrets."cloudflare-api-token".path}"
      }
    '';
  };

  networking.firewall.allowedTCPPorts = [ 80 443 ];
}

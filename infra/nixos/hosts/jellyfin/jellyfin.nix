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
    };

    templates."caddy-env" = {
      owner = "caddy";
      group = "caddy";
      mode = "0400";
      content = ''
        CLOUDFLARE_API_TOKEN="${config.sops.placeholder."cloudflare-api-token"}"
      '';
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
      hash = "sha256-vNSHU7txQLs0m0UChuszURXjEoMj4r1902+1ei0/DaI=";
    };
    
    virtualHosts."jellyfin.middleearth.cc".extraConfig = ''
      reverse_proxy http://localhost:8096
      
      tls {
        dns cloudflare {env.CLOUDFLARE_API_TOKEN}
      }
    '';
  };

  systemd.services.caddy.serviceConfig.EnvironmentFile = [
    config.sops.templates."caddy-env".path
  ];

  networking.firewall.allowedTCPPorts = [ 80 443 ];
}

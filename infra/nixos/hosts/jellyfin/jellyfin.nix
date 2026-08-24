{ config, pkgs, lib, inputs, ... }:

{
  services.jellyfin = {
    enable = true;
    openFirewall = true;
  };

  services.caddy.enable = true;
  services.caddy.virtualHosts."://jellyfin.middleearth.cc".extraConfig = ''
    reverse_proxy http://localhost:8096
  '';

  networking.firewall.allowedTCPPorts = [ 80 443 ];
}

{ config, pkgs, lib, inputs, ... }:

{
  services.jellyfin = {
    enable = true;
    openFirewall = true;
  };
}

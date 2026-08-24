{ config, pkgs, ... }:

{
  imports = [
    ../../modules/base.nix
    ../../modules/container.nix
    ./jellyfin.nix
  ];

  networking.hostName = "jellyfin";

  system.stateVersion = "25.11";
}

{ config, pkgs, ... }:

{
  imports = [
    ../../modules/base.nix
    ../../modules/container.nix
    ./postgres.nix
  ];

  networking.hostName = "postgresql";

  system.stateVersion = "25.11";
}

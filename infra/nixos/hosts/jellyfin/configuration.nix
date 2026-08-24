{ config, pkgs, ... }:

{
  imports = [
    ../../modules/base.nix
    ../../modules/container.nix
    ./jellyfin.nix
  ];

  networking.hostName = "jellyfin";

  system.stateVersion = "25.11";

  boot.supportedFilesystems = ["nfs"];

  fileSystems."/mnt/tower/data" = {
    device = "192.168.40.2:/mnt/user/data";
    fsType = "nfs";
    options = [
      "auto"
    ];
  };
}

{ config, lib, ... }:

{
  boot.isContainer = true;

  fileSystems."/" = {
    device = "none";
    fsType = "tmpfs";
  };

  boot.loader.grub.enable = false;
}

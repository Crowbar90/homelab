{ config, pkgs, ... }:

{
  time.timeZone = "Europe/Rome";

  services.openssh.enable = true;

  environment.systemPackages = with pkgs; [
    vim
    git
    curl
    iproute2
  ];

  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINGq1LqdI1v0Mda8ky+0GE03tPAbSxWE3BEq9DfyCUi0"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM7wZbbmw2oqqFLyIMozCR+aoDt1uVl6EtyWS9byXP8w"
  ];

  sops = {
    age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

    age.keyFile = "/var/lib/sops-nix/key.txt";
    age.generateKey = true;
  };
}

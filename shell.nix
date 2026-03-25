let pkgs = import <nixpkgs> {};

in pkgs.mkShell {
  packages = [
    pkgs.age
    pkgs.gh
    pkgs.git
    pkgs.k9s
    pkgs.kubectl
    pkgs.nixos-rebuild
    pkgs.opentofu
    pkgs.rsync
    pkgs.sops
    pkgs.ssh-to-age
    pkgs.vim
  ];
}

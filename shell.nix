let pkgs = import <nixpkgs> {};

in pkgs.mkShell {
  packages = [
    pkgs.age
    pkgs.gh
    pkgs.git
    pkgs.opentofu
    pkgs.rsync
    pkgs.sops
    pkgs.vim
  ];
}

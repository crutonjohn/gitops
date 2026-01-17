# shell.nix

let
  unstableTarball =
    fetchTarball
      https://github.com/NixOS/nixpkgs/archive/nixos-unstable.tar.gz;
  pkgs = import <nixpkgs> {};
  unstable = import unstableTarball {};

  shell = pkgs.mkShell {
    buildInputs = [
      pkgs.cilium-cli
      pkgs.k0sctl
      pkgs.android-tools
      pkgs.envsubst
      pkgs.ceph
      pkgs.restic
      pkgs.pre-commit
      pkgs.go-task
      pkgs.minijinja
      pkgs.restic
      unstable.talosctl
      unstable.fluxcd
    ];
  };
in shell

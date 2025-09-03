# shell.nix
{ pkgs ? import <nixpkgs> {} }:
  pkgs.mkShell {
    # nativeBuildInputs is usually what you want -- tools you need to run
    nativeBuildInputs = with pkgs.buildPackages; [
      cilium-cli
      k0sctl
      android-tools
      envsubst
      ceph
      restic
      pre-commit
      go-task
      minijinja
      restic
    ];
}

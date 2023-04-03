# shell.nix
{ pkgs ? import <nixpkgs> {} }:
let
  my-python-packages = p: with p; [
    ansible-core
    #(
    #  buildPythonPackage rec {
    #    pname = "python-gilt";
    #    version = "1.2.3";
    #    src = fetchPypi {
    #      inherit pname version;
    #      sha256 = "sha256-0aozmQ4Eb5zL4rtNHSFjEynfObUkYlid1PgMDVmRkwY=";
    #    };
    #    doCheck = false;
    #    propagatedBuildInputs = [
    #      # Specify dependencies
    #    ];
    #  }
    #)
  ];
  my-python = pkgs.python3.withPackages my-python-packages;
in my-python.env

let
  # Choose which nixpkgs set you want here
  Rev = "24.05";

in
# { pkgs ? import <nixpkgs> {} }:
{ pkgs ? import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/refs/heads/nixos-${Rev}.tar.gz") {} }:

(pkgs.buildFHSEnv {
  name = "python-env";
  targetPkgs = pkgs: (with pkgs; [
    python310
    python310Packages.pip
    python310Packages.virtualenv
    # Support binary wheels from PyPI
    pythonManylinuxPackages.manylinux2014Package
    # Enable building from sdists
    cmake
    ninja
    gcc
    pre-commit

    ffmpeg
  ]);
  runScript = pkgs.writeScript "init-venv" ''
    #!/bin/bash
    set -e
    echo "Setting up Python virtual environment..."
    test -d .venv || python3 -m venv .venv
    source .venv/bin/activate
    
    echo "Virtual environment activated at: $VIRTUAL_ENV"
    echo "Python path: $(which python)"
    echo "Pip path: $(which pip)"
    echo "UV will automatically detect the .venv directory"
    exec bash --rcfile <(echo "source .venv/bin/activate")
  '';
}).env
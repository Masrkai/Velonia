#!/bin/sh

# *Define color variables
Cyan='\033[0;36m'
LightGreen='\033[1;32m'
NC='\033[0m'       # Reset Color

# Create source directory
mkdir -p src

# Create a simple C++ source file
echo '#include <iostream>

int main() {
    std::cout << "Hello, World!" << std::endl;
    return 0;
}' > src/main.cpp

# Create CMakeLists.txt file for CMake build configuration
cat << 'EOF' > CMakeLists.txt
cmake_minimum_required(VERSION 3.10)
project(CMS VERSION 1.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 23)

add_executable(output src/main.cpp)
EOF

# Create default.nix for Nix build environment
cat << 'EOF' > shell.nix
{ pkgs ? import <nixpkgs> {} }:

let
  stdenv = pkgs.stdenv;
  cmake = pkgs.cmake;
in
pkgs.mkShell {
  buildInputs = [ cmake ];

  shellHook = ''
    echo "Entering development environment"

    # Save the current PS1 and source shell settings
    export ORIGINAL_PS1="$PS1"

    # Preserve the current shell environment
    if [ -n "$BASH" ]; then
      source ~/.bashrc
    elif [ -n "$ZSH_VERSION" ]; then
      source ~/.zshrc
    fi

    # Restore the original PS1 to prevent nix-shell from changing it
    export PS1="$ORIGINAL_PS1"

    # Create and navigate to the build directory
    build_dir="build"
    mkdir -p "$build_dir"
    cd "$build_dir"

    # Run CMake and Make
    cmake ..
    make

    echo "Build completed. You can find the output in the '$build_dir' directory."
    exit
  '';

  # Avoid overriding PS1
  stdenv.shell.dontRebuildPrompt = true;
}
EOF

# Create a .gitignore file
echo 'result' > .gitignore

# Output completion message
echo -e "${LightGreen}C++ development environment setup complete.${NC}"
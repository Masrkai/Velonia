# Langs/cpp.nix
# clangd / clang-format / clang-tidy come from llvmPackages_23.clang-tools in
# dev/registry.nix. The clang compiler itself stays here.
{ lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    #* Build systems
    cmake
    ninja
    pkg-config
    just
    just-lsp
    gnumake
    buf

    #* Static analysis
    cppcheck

    #* IDE
    qtcreator

    #* Libraries
    eigen
    nlohmann_json

      #* UI toolkits
      gtk3
      gtk4
      kdePackages.qtbase
      kdePackages.qttools

    #* GCC (higher priority to avoid collisions)
    (lib.hiPrio gcc14)

    #* LLVM/Clang compiler (tools are in the registry)
    llvmPackages_23.clang
    llvmPackages_23.bintools

    #* Tests
    gtest
    coreutils-prefixed

    #* Debuggers
    (lib.hiPrio pkgs.gdb)

    bpftools
    bpftrace

    #* Modification
    patchelf

    #* Libs
    stdenv.cc.cc.lib
    gcc.cc.lib
  ];
}

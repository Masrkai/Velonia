# Langs/rust.nix
# rust-analyzer / rustfmt / clippy -> dev/registry.nix (editor tooling).
{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    rustc
    llvmPackages_23.llvm # match the version rustc uses

    cargo
    cargo-edit
    cargo-watch
    cargo-flamegraph
    cargo-nextest
    cargo-llvm-cov
  ];
}

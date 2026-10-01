# Langs/go.nix
# gopls / gofumpt -> dev/registry.nix (editor tooling).
{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    go
    delve # debugger
  ];
}

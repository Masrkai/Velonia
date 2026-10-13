# Langs/nix.nix
# nixd + alejandra -> dev/registry.nix (editor tooling).
{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    nixfmt

    nix-tree
    nix-init

    nixoscope
    nix-eval-jobs
    nix-output-monitor
    nixpkgs-review
    gh
  ];
}

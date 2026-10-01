# In /etc/nixos/Programs/python-libs/default.nix
{ pkgs, ... }:

{
  trl = pkgs.callPackage ./trl.nix {};
  smolagents = pkgs.callPackage ./smolagents.nix {};
  flash-attn = pkgs.callPackage ./flash-attn.nix {};
  cut-cross-entropy = pkgs.callPackage ./cut-cross-entropy.nix {};

  unsloth = pkgs.callPackage ./unsloth/unsloth.nix {};
  unsloth-zoo = pkgs.callPackage ./unsloth/unsloth-zoo.nix {};
}
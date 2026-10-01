{ config, lib, pkgs, ... }:

{
  # Keep your existing nix-ld setup for runtime compatibility
  programs.nix-ld = {
    enable = true;
  };
}
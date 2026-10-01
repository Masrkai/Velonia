{ config, lib, pkgs, ... }:
{
      imports =
    [ # Include the results of the hardware scan.
      ../networking.nix
      ../security.nix
      ../bash.nix
    ];




}
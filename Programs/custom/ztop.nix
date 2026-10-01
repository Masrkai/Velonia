{ config, pkgs, ... }:

let
  Pythonpkgs = import ./Python/ztop.nix { inherit pkgs; };
in
{

  environment.systemPackages = with pkgs; [

    Pythonpkgs.ctj
    # Pythonpkgs.MD-PDF
    Pythonpkgs.mac-formatter
  ];
}

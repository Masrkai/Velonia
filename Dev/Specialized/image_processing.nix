{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [

  exiv2

  # Not needed currently
  # (octaveFull.withPackages (opkgs: with opkgs; [
  #   image
  # ]))

  ];
}

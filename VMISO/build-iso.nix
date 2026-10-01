# { pkgs, lib, ... }:

let
  nixosPkgs = import <nixpkgs> {};
  nixosSrc = nixosPkgs.path;

  nixosSystem = nixosPkgs.nixos {
      imports = [
        "${nixosSrc}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
        /etc/nixos/VMISO/iso.nix
      ];
  };
in
{
  iso = nixosSystem.config.system.build.isoImage;
}
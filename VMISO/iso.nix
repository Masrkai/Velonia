{ config, pkgs, lib, ... }:

{
  imports = [
    ../configuration.nix  # Import your existing configuration
    <nixpkgs/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix>
  ];

  boot.loader.timeout = lib.mkForce 10;

  # ISO-specific options
  boot.loader.grub.memtest86.enable = true;
  boot.supportedFilesystems = [ "ext4" "btrfs" "reiserfs" "vfat" "f2fs" "xfs" "ntfs" "cifs" ];

  # Enable copy-on-write for the ISO
  isoImage.squashfsCompression = "zstd -Xcompression-level 6";

  # Optional: Set a custom ISO name
  isoImage.isoName = "Main_NixOS_System.iso";
}
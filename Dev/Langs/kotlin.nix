# Langs/kotlin.nix
# kotlin-language-server / ktfmt / ktlint -> dev/registry.nix (editor tooling).
{ pkgs, lib, ... }:

{
  environment.systemPackages = with pkgs; [
    (lib.lowPrio kotlin)
    kotlin-native
    kotlin-interactive-shell
  ];
}

{pkgs, ... }:

{

  nix-nixpkgs-extensions = with pkgs.vscode-extensions; [
    mkhl.direnv
    jnoortheen.nix-ide
    arrterian.nix-env-selector
    # jeff-hykin.better-nix-syntax
  ];

  nix-marketplace-extensions = with pkgs.vscode-utils.extensionsFromVscodeMarketplace; [

  ];
}
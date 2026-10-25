{ pkgs, ... }:

{
  lua-nixpkgs-extensions = with pkgs.vscode-extensions; [
    sumneko.lua
  ];

  lua-marketplace-extensions = with pkgs.vscode-utils.extensionsFromVscodeMarketplace; [

  ];
}

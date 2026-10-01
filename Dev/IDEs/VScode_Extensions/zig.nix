{ lib, pkgs, ... }:

{

  zig-nixpkgs-extensions = with pkgs.vscode-extensions; [
   ziglang.vscode-zig
  ];

  zig-marketplace-extensions = with pkgs.vscode-utils.extensionsFromVscodeMarketplace; [

  ];
}
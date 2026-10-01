{ pkgs, ... }:

{

  rust-nixpkgs-extensions = with pkgs.vscode-extensions; [
    fill-labs.dependi
    rust-lang.rust-analyzer
    tamasfe.even-better-toml
  ];

  rust-marketplace-extensions = with pkgs.vscode-utils.extensionsFromVscodeMarketplace; [

  ];
}
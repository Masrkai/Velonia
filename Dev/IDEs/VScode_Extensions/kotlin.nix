{ pkgs, ... }:

{

  kotlin-nixpkgs-extensions = with pkgs.vscode-extensions; [

  ];

  kotlin-marketplace-extensions = with pkgs.vscode-utils.extensionsFromVscodeMarketplace; [
      {
        #https://open-vsx.org/extension/fwcd/kotlin
        name = "kotlin";
        publisher = "fwcd";
        version = "0.2.36";
        hash = "sha256-tCpxFWSQZNhiHdJyxSbQ1QakS2jNqWQrA2/grLZklrM=";
      }
  ];
}
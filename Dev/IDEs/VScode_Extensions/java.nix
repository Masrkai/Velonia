{pkgs, ... }:

{

  java-nixpkgs-extensions = with pkgs.vscode-extensions; [
    redhat.java
    vscjava.vscode-java-test
    vscjava.vscode-java-debug
    vscjava.vscode-java-dependency

  ];

  java-marketplace-extensions = with pkgs.vscode-utils.extensionsFromVscodeMarketplace; [

  ];
}
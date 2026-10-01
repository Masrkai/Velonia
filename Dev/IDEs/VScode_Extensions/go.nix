{pkgs, lib, ... }:

{

  golang-nixpkgs-extensions = with pkgs.vscode-extensions; [
    golang.go
    # zxh404.vscode-proto3
  ];

  golang-marketplace-extensions = [
      # {
      #   #https://open-vsx.org/vscode/item?itemName=766b.go-outliner
      #   name = "go-outliner";
      #   publisher = "766b";
      #   version = "0.1.21";
      #   # hash = lib.fakeHash;
      #   hash = "sha256-4uAXDZ8sMPnUaLCEDK9QdU+IB/s9rcHgEEXAmgEMLuA=";
      # }
  ];
}

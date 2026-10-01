{ pkgs, ... }:

{
   environment.systemPackages = with pkgs; [
     slint-lsp
     slint-viewer
  ];
}
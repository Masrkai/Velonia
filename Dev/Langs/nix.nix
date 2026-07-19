{pkgs, config, ... }:

{
  environment.systemPackages = with pkgs; [
    nixd
    nixfmt
    alejandra

    direnv
    nix-tree
    nix-init
    pkgs.nixoscope
    nix-direnv
    nix-eval-jobs
    nix-output-monitor
    nixpkgs-review gh
  ];

}
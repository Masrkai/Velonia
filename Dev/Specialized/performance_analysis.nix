{ pkgs, ... }:

{
   environment.systemPackages = with pkgs; [
    perf

    bcc
    bpftools
  ];
}
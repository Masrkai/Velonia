{ pkgs, ... }:

{
   environment.systemPackages = with pkgs; [
    perf
    perf-tools

    bcc
    bpftools
  ];
}
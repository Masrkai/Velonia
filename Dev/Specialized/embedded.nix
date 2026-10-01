{ pkgs, ... }:

{
   environment.systemPackages = with pkgs; [
    picocom
    screen

    openocd
  ];
}
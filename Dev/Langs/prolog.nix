{ pkgs, ... }:

{
    environment.systemPackages = with pkgs; [
      swi-prolog
    ];

}
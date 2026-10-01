{ pkgs, ... }:

{

   programs.java = {
      enable = true;
      binfmt = true;
   };

   environment.systemPackages = with pkgs; [
    gradle
   ];
}
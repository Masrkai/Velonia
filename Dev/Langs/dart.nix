{ pkgs, ... }:

{
   environment.systemPackages = with pkgs; [

    # Flutter framework (includes Dart SDK)
    flutter     #? Dart SDK and runtime are provided by flutter
   ];
}
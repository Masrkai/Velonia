{ pkgs, ... }:

{
  dart-nixpkgs-extensions = with pkgs.vscode-extensions; [
    # Official Dart language support
    dart-code.dart-code

    # Official Flutter extension
    dart-code.flutter
  ];

  dart-marketplace-extensions = with pkgs.vscode-utils.extensionsFromVscodeMarketplace; [
    # You can add additional Flutter/Dart extensions here if needed
  ];
}
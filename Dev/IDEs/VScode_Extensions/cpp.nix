{ lib, pkgs, ... }:

{
  cpp-nixpkgs-extensions = with pkgs.vscode-extensions; [
    # twxs.cmake
    vadimcn.vscode-lldb
    ms-vscode.cmake-tools
    llvm-vs-code-extensions.vscode-clangd
  ];

  cpp-marketplace-extensions = with pkgs.vscode-utils.extensionsFromVscodeMarketplace; [
    {
      # https://marketplace.visualstudio.com/items?itemName=nefrob.vscode-just-syntax
      name = "vscode-just-syntax";
      publisher = "nefrob";
      version = "0.10.2";
      hash = "sha256-F7H9f24TjB3JtWLVICYwRTjxa+GTOpYN7IzSlU1audo=";
    }
    {
      # https://open-vsx.org/extension/bufbuild/vscode-buf
      name = "vscode-buf";
      publisher = "bufbuild";
      version = "0.8.19";
      hash = "sha256-SlWtQ+4q3TfXJ6ydR2/m39maZ/8KKbgXSYEsWOLyenA=";
    }
    {
      # https://marketplace.visualstudio.com/items?itemName=cheshirekow.cmake-format
      name = "cmake-format";
      publisher = "cheshirekow";
      version = "0.6.11";
      hash = "sha256-NdU8J0rkrH5dFcLs8p4n/j2VpSP/X7eSz2j4CMDiYJM=";
    }
    {
      #https://open-vsx.org/extension/KylinIdeTeam/cmake-intellisence
      name = "cmake-intellisence";
      publisher = "KylinIdeTeam";
      version = "0.3.3";
      hash = "sha256-wCT5I1qobNmXaO7otoe6Tdg2p7a3CgUk5pc5BJW3r20=";
    }
  ];
}
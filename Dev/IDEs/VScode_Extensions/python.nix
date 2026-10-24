{ pkgs, ... }:

{

  python-nixpkgs-extensions = with pkgs.vscode-extensions; [
    #* Python
    ms-python.python
    ms-python.debugpy

    charliermarsh.ruff
    # basedpyright replaced by pyrefly (marketplace entry below)

      #->Jupyter
      ms-toolsai.jupyter
      ms-toolsai.jupyter-keymap
      ms-toolsai.jupyter-renderers
      ms-toolsai.vscode-jupyter-slideshow
      ms-toolsai.vscode-jupyter-cell-tags

  ];

  python-marketplace-extensions = with pkgs.vscode-utils.extensionsFromVscodeMarketplace; [
    # Pyrefly (Meta's Python type checker / LSP), replaces basedpyright.
    # https://open-vsx.org/extension/meta/pyrefly
    {
      name = "pyrefly";
      publisher = "meta";
      version = "1.4.0";
      sha256 = "sha256-7Fxa6JZzV7Wl/9V5fE3p99nzelYLEPNV3Yt3W1XMAwM=";
    }

    # {
    #   #https://marketplace.visualstudio.com/items?itemName=marimo-team.vscode-marimo
    #   name = "vscode-marimo";
    #   publisher = "marimo-team";
    #   version = "0.13.5";
    #   hash = "sha256-TnHSRoLpKFu1N33tRDgqDKm8kqD0AtZCpZgsZd1iZY8=";
    # }


  ];
}

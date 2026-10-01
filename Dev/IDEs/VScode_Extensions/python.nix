{ pkgs, ... }:

{

  python-nixpkgs-extensions = with pkgs.vscode-extensions; [
    #* Python
    ms-python.python
    ms-python.debugpy

    charliermarsh.ruff
    detachhead.basedpyright

      #->Jupyter
      # ms-toolsai.jupyter
      # ms-toolsai.jupyter-keymap
      # ms-toolsai.jupyter-renderers
      # ms-toolsai.vscode-jupyter-slideshow
      # ms-toolsai.vscode-jupyter-cell-tags

  ];

  python-marketplace-extensions = with pkgs.vscode-utils.extensionsFromVscodeMarketplace; [

    {
      #https://marketplace.visualstudio.com/items?itemName=marimo-team.vscode-marimo
      name = "vscode-marimo";
      publisher = "marimo-team";
      version = "0.13.5";
      hash = "sha256-TnHSRoLpKFu1N33tRDgqDKm8kqD0AtZCpZgsZd1iZY8=";
    }


  ];
}

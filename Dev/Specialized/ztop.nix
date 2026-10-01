{pkgs, ...}:

{
  imports = [
    # commented out because of "no longer needed" reasons but keeping configs just in case
    # ./android.nix
    # ./big_data.nix
    # ./jupyter.nix
    ./DBs/ztop.nix

    # SWE Toolkits
    ./UML.nix
    ./Docs.nix
    ./GUIs.nix
    ./embedded.nix
    ./image_processing.nix
    ./performance_analysis.nix

  ];

}

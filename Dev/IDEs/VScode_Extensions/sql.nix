{ lib, pkgs, ... }:

{

  sql-nixpkgs-extensions = with pkgs.vscode-extensions; [
   jebbs.plantuml
   cweijan.vscode-database-client2
  ];

  sql-marketplace-extensions = with pkgs.vscode-utils.extensionsFromVscodeMarketplace; [

      {
        #https://marketplace.visualstudio.com/items?itemName=yy0931.vscode-sqlite3-editor
        name = "vscode-sqlite3-editor";
        publisher = "yy0931";
        version = "1.0.189";
        hash = "sha256-zlZTb9zBSWsnZrcYArW1x4hjHzlAp6ITe4TPuUdYazI=";
      }

      # {
      #   # https://open-vsx.org/extension/dvirtz/parquet-viewer


      #   name = "parquet-viewer";
      #   publisher = "dvirtz";
      #   version = "3.1.0";
      #   hash = "sha256-W+r5KIzg2J7QZ+JalskSQ7EMiIokXC0clpzJnpg13VI=";

      # }


      {
        # https://open-vsx.org/extension/DiegoScirocco/grid-master

        name = "grid-master";
        publisher = "DiegoScirocco";
        version = "0.6.0";
        hash = "sha256-hAnTueHMz5J7Ookecei5qJjBFFz1LHZ3sUzmoZs4uxQ=";

      }

  ];
}
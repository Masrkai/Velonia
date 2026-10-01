{ pkgs, ... }:

{

  prolog-nixpkgs-extensions = with pkgs.vscode-extensions; [
  ];

  prolog-marketplace-extensions = with pkgs.vscode-utils.extensionsFromVscodeMarketplace; [

    {
      # https://marketplace.visualstudio.com/items?itemName=AmauryRabouan.new-vsc-prolog
      name = "new-vsc-prolog";
      publisher = "AmauryRabouan";
      version = "1.1.15";
      hash = "sha256-B3Yhkfeu14nDa0EbKqLB58eH7S6GzSovwgKYH867eKc=";
    }


  ];
}

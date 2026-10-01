{ pkgs, ... }:

{

  UML-nixpkgs-extensions = with pkgs.vscode-extensions; [
    hediet.vscode-drawio
  ];

  UML-marketplace-extensions = with pkgs.vscode-utils.extensionsFromVscodeMarketplace; [
    {
      #corschenzi.mermaid-graphical-editor
      name = "mermaid-graphical-editor";
      publisher = "corschenzi";
      version = "0.4.8";
      hash = "sha256-CB4oWbSxxIAaBBXxSM+jURdhmHPF+oK/UdcIKCZ1vNk=";
    }
   #>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    {
      #https://open-vsx.org/api/bpruitt-goddard/mermaid-markdown-syntax-highlighting
      name = "mermaid-markdown-syntax-highlighting";
      publisher = "bpruitt-goddard";
      version = "1.6.6";
      hash = "sha256-1WwjGaYNHN6axlprjznF1S8BB4cQLnNFXqi7doQZjrQ=";
    }
  ];
}
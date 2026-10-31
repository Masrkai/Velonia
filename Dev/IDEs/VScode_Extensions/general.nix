{ lib, pkgs, ... }:

{

  general-nixpkgs-extensions = with pkgs.vscode-extensions; [
    # continue.continue
    davidanson.vscode-markdownlint
  ];

  general-marketplace-extensions = with pkgs.vscode-utils.extensionsFromVscodeMarketplace; [
      # NOTE: lukin-vscode-theme moved to the shared set in ../vscodium.nix
      # (installed in every profile).


#      {
#        #https://marketplace.visualstudio.com/items?itemName=Slint.slint
#        name = "slint";
#        publisher = "Slint";
#        version = "1.17.1";
#        hash = "";
#      }


      {
        # https://marketplace.visualstudio.com/items?itemName=bpfdeploy.bpftrace
        name = "bpftrace";
        publisher = "bpfdeploy";
        version = "0.2.1";
        hash = "sha256-zXym/ogqdlG9AIiIv4nC/ZUMKd668ft5mWhwLXp7rvw=";
        # hash = lib.fakeHash;
      }



      {
        # https://marketplace.visualstudio.com/items?itemName=aykutsarac.jsoncrack-vscode
        name = "jsoncrack-vscode";
        publisher = "aykutsarac";
        version = "5.0.0";
        hash = "sha256-ctJdpLeZLTm+IsuPHw2pvSVoiiNG9Nzm/YVmaz7jQKQ=";
      }



      {
        # https://marketplace.visualstudio.com/items?itemName=dtoplak.vscode-glsllint
        name = "vscode-glsllint";
        publisher = "dtoplak";
        version = "1.9.1";
        hash = "sha256-59RNmILdshkAYjpeNz+gjq+WuDKZ/IMNVdzVl8HLFaA=";
        # hash = lib.fakeHash;
      }
      {
        # https://open-vsx.org/extension/slevesque/shader
        name = "shader";
        publisher = "slevesque";
        version = "1.1.5";
        hash = "sha256-Pf37FeQMNlv74f7LMz9+CKscF6UjTZ7ZpcaZFKtX2ZM=";
        # hash = lib.fakeHash;
      }


      # https://open-vsx.org/extension/13xforever/language-x86-64-assembly
      {
              name = "language-x86-64-assembly";
              publisher = "13xforever";
              version = "3.1.5";
              hash = "sha256-WIhmAZLR2WOSqQF3ozJ/Vr3Rp6HdSK7L23T3h4AVaGM=";
              # hash = lib.fakeHash;

      }
      {
        #https://marketplace.visualstudio.com/items?itemName=LucasFA.octaveexecution
        name = "octaveexecution";
        publisher = "LucasFA";
        version = "0.7.6";
        # hash = lib.fakeHash;
        hash = "sha256-oQ8Bwo7bCb0ecHrJz84Uisc4WgbuByfEol3luHZfSB8=";
      }
      {
        #https://open-vsx.org/extension/eliostruyf/screendown
        name = "screendown";
        publisher = "eliostruyf";
        version = "0.0.23";
        hash = "sha256-ZHa4N1QTj7XAizWgeXzRGohhsSbxdPJv1rtCib4sQsU=";
      }
      {
        #https://open-vsx.org/extension/ultram4rine/vscode-choosealicense
        name = "vscode-choosealicense";
        publisher = "ultram4rine";
        version = "0.9.4";
        hash = "sha256-YmZ1Szvcv3E3q8JVNV1OirXFdYI29a4mR3rnhJfUSMM=";
      }
      {
        #https://open-vsx.org/extension/markwylde/vscode-filesize
        name = "vscode-filesize";
        publisher = "mkxml";
        version = "3.1.0";
        hash = "sha256-5485MjY3kMdeq/Z2mYaNjPj1XA+xRHizMrQDWDLWrf8=";
      }
      {
        #https://marketplace.visualstudio.com/items?itemName=darkriszty.markdown-table-prettify
        name = "markdown-table-prettify";
        publisher = "darkriszty";
        version = "3.6.0";  # Check for the latest version
        hash = "sha256-FZTiNGSY+8xk3DJsTKQu4AHy1UFvg0gbrzPpjqRlECI=";
      }
      # {
      #   #https://marketplace.visualstudio.com/items?itemName=goessner.mdmath
      #   name = "mdmath";
      #   publisher = "goessner";
      #   version = "2.7.4";  # Check for the latest version
      #   hash = "sha256-DCh6SG7nckDxWLQvHZzkg3fH0V0KFzmryzSB7XTCj6s=";
      # }
      {
        #https://marketplace.visualstudio.com/items?itemName=shellscape.shellscape-brackets
        name = "shellscape-brackets";
        publisher = "shellscape";
        version = "0.1.2";  # Check for the latest version
        hash = "sha256-dcxtgUfn2GhVVyTxd+6mC0bhwMeLUxB6T9mPBUbgxbA=";
      }

      # {
      #   # https://open-vsx.org/extension/quarto/quarto
      #   name = "quarto";
      #   publisher = "quarto";
      #   version = "1.126.0";  # Check for the latest version
      #   hash = "sha256-tt/rMTf6chRRLfrsJytUFPvlcgcUE7/7GvPxyZVyvbA=";
      # }



  ];
}

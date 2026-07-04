#*#########################
#* Vscodium Configuration:
#*#########################

{ lib, pkgs, config, ... }:

let
  # unstable = import <unstable> {config.allowUnfree = true;};

  sql      = import ./VScode_Extensions/sql.nix     { inherit pkgs lib ; };
  cpp      = import ./VScode_Extensions/cpp.nix     { inherit pkgs lib ; };
  zig      = import ./VScode_Extensions/zig.nix     { inherit pkgs lib ; };
  nixX     = import ./VScode_Extensions/nix.nix     { inherit pkgs lib ; };
  umlx     = import ./VScode_Extensions/UML.nix     { inherit pkgs lib ; };
  java     = import ./VScode_Extensions/java.nix    { inherit pkgs lib ; };
  rust     = import ./VScode_Extensions/rust.nix    { inherit pkgs lib ; };
  dartX    = import ./VScode_Extensions/dart.nix    { inherit pkgs lib ; };
  golang   = import ./VScode_Extensions/go.nix      { inherit pkgs lib ; };
  prolog   = import ./VScode_Extensions/prolog.nix  { inherit pkgs lib ; };
  kotlinX  = import ./VScode_Extensions/kotlin.nix  { inherit pkgs lib ; };
  pythonX  = import ./VScode_Extensions/python.nix  { inherit pkgs lib ; };
  generalX = import ./VScode_Extensions/general.nix { inherit pkgs lib ; };

in{
  environment.systemPackages = with pkgs; [

      (vscode-with-extensions.override {
        vscode = vscodium;
        vscodeExtensions = with vscode-extensions; [
                            #* HTML
                            # ms-vscode.live-server
                            vscode-extensions.ritwickdey.liveserver

                            #* PDF
                            tomoki1207.pdf

                            #* Bash
                            mads-hartmann.bash-ide-vscode

                            #* Markdown
                            bierner.markdown-mermaid
                            shd101wyy.markdown-preview-enhanced
                            # garlicbreadcleric.pandoc-markdown-syntax

                            #* Yamal
                            redhat.vscode-yaml

                            #* General
                            usernamehw.errorlens
                            donjayamanne.githistory      #> GIT History
                            mechatroner.rainbow-csv      #> For .csv files!
                            formulahendry.code-runner
                            shardulm94.trailing-spaces
                            aaron-bond.better-comments

                            tekumara.typos-vscode
                            # streetsidesoftware.code-spell-checker

                            #? theming
                            pkief.material-icon-theme

                            #* VS-Codium Specific
                            editorconfig.editorconfig
                            github.vscode-pull-request-github

                            #? SSH
                            ms-vscode-remote.remote-ssh
                            ms-vscode-remote.remote-ssh-edit

                            #? MATLAB
                            # MathWorks.language-matlab
        ]
        ++ sql.sql-nixpkgs-extensions
        ++ cpp.cpp-nixpkgs-extensions
        ++ zig.zig-nixpkgs-extensions
        ++ umlx.UML-nixpkgs-extensions
        ++ nixX.nix-nixpkgs-extensions
        ++ java.java-nixpkgs-extensions
        ++ rust.rust-nixpkgs-extensions
        ++ dartX.dart-nixpkgs-extensions
        ++ pythonX.python-nixpkgs-extensions
        ++ generalX.general-nixpkgs-extensions
        ++ golang.golang-nixpkgs-extensions
        ++ prolog.prolog-nixpkgs-extensions


        ++ vscode-utils.extensionsFromVscodeMarketplace (
          cpp.cpp-marketplace-extensions
          ++ sql.sql-marketplace-extensions
          ++ umlx.UML-marketplace-extensions
          ++ nixX.nix-marketplace-extensions
          ++ rust.rust-marketplace-extensions
          ++ dartX.dart-marketplace-extensions
          ++ golang.golang-marketplace-extensions
          ++ kotlinX.kotlin-marketplace-extensions
          ++ pythonX.python-marketplace-extensions
          ++ generalX.general-marketplace-extensions
          ++ prolog.prolog-marketplace-extensions

        );
      })
  ];


  system.userActivationScripts.vscode-config = ''
    mkdir -p ~/.config/VSCodium/User
    cp ${./vscode_config.jsonc} ~/.config/VSCodium/User/settings.json
  '';

}

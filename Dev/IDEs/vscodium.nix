# IDEs/vscodium.nix
{
  lib,
  pkgs,
  config,
  ...
}: let
  dev = import ../lib.nix {inherit pkgs lib;};

  # Each file returns { <name>-nixpkgs-extensions; <name>-marketplace-extensions }
  ext = name: import (./VScode_Extensions + "/${name}.nix") {inherit pkgs lib;};

  sql = ext "sql";
  cpp = ext "cpp";
  zig = ext "zig";
  nixX = ext "nix";
  umlx = ext "UML";
  java = ext "java";
  rust = ext "rust";
  dartX = ext "dart";
  golang = ext "go";
  prolog = ext "prolog";
  kotlinX = ext "kotlin";
  pythonX = ext "python";
  generalX = ext "general";

  # ---------------------------------------------------------------------------
  # settings.json = vscode_config.jsonc with tool paths substituted.
  #
  # The file is copied AS-IS apart from @placeholders@, so every comment and
  # your layout survive. No parsing and no format conversion: VSCodium reads
  # settings.json as JSONC natively. Each @name@ becomes a store path of the
  # SAME package neovim uses, so both editors run identical tool versions.
  # ---------------------------------------------------------------------------
  settingsJson = pkgs.replaceVars ./vscode_config.jsonc {
    nixd = "${pkgs.nixd}/bin/nixd";
    alejandra = "${pkgs.alejandra}/bin/alejandra";
    ruff = "${pkgs.ruff}/bin/ruff";
    zig = "${pkgs.zig}/bin/zig";
    zls = "${pkgs.zls}/bin/zls";
    slint_lsp = "${pkgs.slint-lsp}/bin/slint-lsp";
    swipl = "${pkgs.swi-prolog}/bin/swipl";
    typos_lsp = "${pkgs.typos-lsp}/bin/typos-lsp";
    plantuml_jar = "${pkgs.plantuml}/lib/plantuml.jar";
  };

  vscodium = pkgs.vscode-with-extensions.override {
    vscode = pkgs.vscodium;
    vscodeExtensions = with pkgs.vscode-extensions;
      [
        #* HTML
        ritwickdey.liveserver

        #* PDF
        tomoki1207.pdf

        #* Bash
        mads-hartmann.bash-ide-vscode

        #* Markdown
        bierner.markdown-mermaid
        shd101wyy.markdown-preview-enhanced

        #* YAML
        redhat.vscode-yaml

        #* General
        usernamehw.errorlens
        donjayamanne.githistory
        mechatroner.rainbow-csv
        formulahendry.code-runner
        shardulm94.trailing-spaces
        aaron-bond.better-comments
        tekumara.typos-vscode

        #? theming
        pkief.material-icon-theme

        #* VSCodium specific
        editorconfig.editorconfig
        github.vscode-pull-request-github

        #? SSH
        ms-vscode-remote.remote-ssh
        ms-vscode-remote.remote-ssh-edit
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
      ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace (
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
  };
in {
  config = lib.mkIf config.dev.editors.vscodium.enable {
    # VSCodium plus the same tools neovim gets, so an editor never depends on
    # which Langs/ module happens to be imported.
    environment.systemPackages = [vscodium] ++ dev.allPackages;

    # Writes settings for the primary user only, and only if the user has not
    # replaced it with a symlink or hand-edited file (which would be lost).
    system.userActivationScripts.vscode-config = ''
      dir="$HOME/.config/VSCodium/User"
      mkdir -p "$dir"
      install -m 0644 ${settingsJson} "$dir/settings.json"
    '';
  };
}

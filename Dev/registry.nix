# dev/registry.nix
#
# SINGLE SOURCE OF TRUTH for editor-facing tooling.
#
# Every language declares:
#   packages   - tools to put on PATH (LSP, formatter, linter)
#   filetypes  - vim filetypes this entry applies to
#   lsp        - { nvim = "<lspconfig name>"; vscode = { ... } }   (optional)
#   formatter  - { nvim = "<conform name>"; }                      (optional)
#   linter     - { nvim = "<nvim-lint name>"; }                    (optional)
#
# Compilers / runtimes / build systems stay in Langs/*.nix. This file is only
# what an EDITOR needs, so neovim and VSCodium can never disagree.
#
# VSCodium tool paths are substituted into vscode_config.json by vscodium.nix
# from the SAME packages listed here, so there is one version of each tool.
{
  pkgs,
  lib,
  ...
}: {
  languages = {
    nix = {
      packages = with pkgs; [nixd alejandra];
      filetypes = ["nix"];
      lsp.nvim = "nixd";
      formatter.nvim = "alejandra";
      linter.nvim = null;
      nvimLspSettings = {
        nixd.settings.formatting.command = ["alejandra"];
      };
    };

    python = {
      packages = with pkgs; [ruff basedpyright];
      filetypes = ["python"];
      # Neovim gets BOTH a type checker and ruff, matching VSCodium.
      lsp.nvim = ["basedpyright" "ruff"];
      formatter.nvim = "ruff_format";
      linter.nvim = "ruff";
    };

    cpp = {
      packages = with pkgs; [llvmPackages_23.clang-tools];
      filetypes = ["c" "cpp"];
      lsp.nvim = "clangd";
      formatter.nvim = "clang_format";
      linter.nvim = "clangtidy";
    };

    rust = {
      packages = with pkgs; [rust-analyzer rustfmt clippy];
      filetypes = ["rust"];
      lsp.nvim = "rust_analyzer";
      formatter.nvim = "rustfmt";
      linter.nvim = null;
    };

    go = {
      packages = with pkgs; [gopls gofumpt delve];
      filetypes = ["go"];
      lsp.nvim = "gopls";
      formatter.nvim = "gofumpt";
      linter.nvim = null;
    };

    zig = {
      packages = with pkgs; [zig zls];
      filetypes = ["zig"];
      lsp.nvim = "zls";
      formatter.nvim = null; # zls formats through LSP
      linter.nvim = null;
    };

    kotlin = {
      packages = with pkgs; [kotlin-language-server ktfmt ktlint];
      filetypes = ["kotlin"];
      lsp.nvim = "kotlin_language_server";
      formatter.nvim = "ktfmt";
      linter.nvim = "ktlint";
    };

    java = {
      packages = with pkgs; [jdt-language-server];
      filetypes = ["java"];
      lsp.nvim = "jdtls";
      formatter.nvim = null;
      linter.nvim = null;
    };

    dart = {
      # Dart SDK comes from flutter in Langs/dart.nix
      packages = [];
      filetypes = ["dart"];
      lsp.nvim = "dartls";
      formatter.nvim = null;
      linter.nvim = null;
    };

    bash = {
      packages = with pkgs; [bash-language-server shellcheck shfmt];
      filetypes = ["sh" "bash"];
      lsp.nvim = "bashls";
      formatter.nvim = "shfmt";
      linter.nvim = "shellcheck";
    };

    markdown = {
      packages = with pkgs; [markdownlint-cli marksman];
      filetypes = ["markdown"];
      lsp.nvim = "marksman";
      formatter.nvim = "markdownlint";
      linter.nvim = "markdownlint";
    };

    yaml = {
      packages = with pkgs; [yaml-language-server yamlfmt];
      filetypes = ["yaml"];
      lsp.nvim = "yamlls";
      formatter.nvim = "yamlfmt";
      linter.nvim = null;
    };

    json = {
      packages = with pkgs; [vscode-langservers-extracted jq];
      filetypes = ["json"];
      lsp.nvim = "jsonls";
      formatter.nvim = "jq";
      linter.nvim = null;
    };

    cmake = {
      packages = with pkgs; [cmake-language-server];
      filetypes = ["cmake"];
      lsp.nvim = "cmake";
      formatter.nvim = null;
      linter.nvim = null;
    };

    prolog = {
      packages = [];
      filetypes = ["prolog"];
      lsp.nvim = null; # swipl's lsp_server pack is not packaged in nixpkgs
      formatter.nvim = null;
      linter.nvim = null;
    };

    slint = {
      packages = with pkgs; [slint-lsp];
      filetypes = ["slint"];
      lsp.nvim = null; # lspconfig has no stable slint entry on all releases
      formatter.nvim = null;
      linter.nvim = null;
    };

    plantuml = {
      packages = with pkgs; [plantuml graphviz];
      filetypes = ["plantuml"];
      lsp.nvim = null;
      formatter.nvim = null;
      linter.nvim = null;
    };

    typos = {
      packages = with pkgs; [typos typos-lsp];
      filetypes = [];
      lsp.nvim = null;
      formatter.nvim = null;
      linter.nvim = null;
    };
  };
}

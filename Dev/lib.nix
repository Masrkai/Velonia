# dev/lib.nix
# Turns registry.nix into flat, editor-ready values.
{
  pkgs,
  lib,
  ...
}: let
  reg = (import ./registry.nix {inherit pkgs lib;}).languages;
  langs = lib.attrValues reg;

  # "x" -> ["x"], ["x" "y"] -> same, null -> []
  toList' = v:
    if v == null
    then []
    else if builtins.isList v
    then v
    else [v];
in rec {
  inherit reg;

  # Every package any editor needs on PATH.
  allPackages = lib.unique (lib.concatMap (l: l.packages or []) langs);

  # Neovim LSP server names, de-duplicated.
  nvimLspServers = lib.unique (lib.concatMap (l: toList' (l.lsp.nvim or null)) langs);

  # Extra per-server lspconfig settings declared in the registry.
  nvimLspSettings =
    lib.foldl' lib.recursiveUpdate {}
    (map (l: l.nvimLspSettings or {}) langs);

  # { filetype = [ "formatter" ]; }
  nvimFormattersByFt = lib.foldl' (acc: l: let
    f = toList' (l.formatter.nvim or null);
  in
    if f == []
    then acc
    else acc // lib.genAttrs l.filetypes (_: f)) {}
  langs;

  # { filetype = [ "linter" ]; }
  nvimLintersByFt = lib.foldl' (acc: l: let
    f = toList' (l.linter.nvim or null);
  in
    if f == []
    then acc
    else acc // lib.genAttrs l.filetypes (_: f)) {}
  langs;
}

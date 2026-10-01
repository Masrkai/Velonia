# Dev environment: single source of truth

    dev/
    ├── registry.nix        <- ONE place declaring LSP/formatter/linter per language
    ├── lib.nix             <- flattens the registry for consumers
    ├── IDEs/
    │   ├── default.nix     <- dev.editors.* options, driven by ID.nix flags
    │   ├── nvim.nix        <- generated from registry (pinned via fetchGit)
    │   ├── vscodium.nix    <- settings.json = vscode_config.json (+) registry
    │   ├── vscode_config.json  <- plain JSON, read with builtins.fromJSON
    │   └── ...
    └── Langs/              <- compilers/runtimes/build tools ONLY

## Editor selection (ID.nix)

| Hardware  | neovim | VSCodium |
|-----------|--------|----------|
| ThinkPad  | yes    | yes      |
| others    | yes    | yes      |

Override per machine: `dev.editors.vscodium.enable = true;` (VSCodium defaults to enabled across environments).

## Adding a language
Add ONE entry to `registry.nix`. Both editors pick it up.

## First-build checklist
1. `builtins.fetchGit` pin for nixvim is used in `nvim.nix` (pinned commit hash ensures reproducible builds without manual `fakeSha256` hashing).
2. `sudo mkdir -p /etc/arcadedb && echo 'ARCADEDB_ROOT_PASSWORD=...' | sudo tee /etc/arcadedb/credentials && sudo chmod 600 /etc/arcadedb/credentials` (if ArcadeDB service is enabled).
3. `nixos-rebuild dry-build`, then fix any option-name drift.

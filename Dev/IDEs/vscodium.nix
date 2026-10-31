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
  luaX = ext "lua";

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
    pyrefly = "${pkgs.pyrefly}/bin/pyrefly";
    zig = "${pkgs.zig}/bin/zig";
    zls = "${pkgs.zls}/bin/zls";
    slint_lsp = "${pkgs.slint-lsp}/bin/slint-lsp";
    swipl = "${pkgs.swi-prolog}/bin/swipl";
    typos_lsp = "${pkgs.typos-lsp}/bin/typos-lsp";
    plantuml_jar = "${pkgs.plantuml}/lib/plantuml.jar";
  };

  # ---------------------------------------------------------------------------
  # Extension profiles for home-manager's programs.vscode.
  #
  # sharedExtensions go into EVERY profile (editor-agnostic core). Everything
  # else is per-profile: `default` carries the web/doc tooling plus general.nix,
  # and each language gets its own profile built from its
  # VScode_Extensions/<lang>.nix file, so switching profiles in VSCodium swaps
  # the extension set. mutableExtensionsDir = false makes HM own the
  # extensions dir; each profile gets its own immutable extension store.
  # ---------------------------------------------------------------------------
  sharedExtensions = with pkgs.vscode-extensions; [
    #* General
    usernamehw.errorlens
    mechatroner.rainbow-csv
    formulahendry.code-runner
    shardulm94.trailing-spaces
    aaron-bond.better-comments
    tekumara.typos-vscode

    #? theming
    pkief.material-icon-theme

    #? VSCodium specific
    editorconfig.editorconfig

    #? SSH
    ms-vscode-remote.remote-ssh
    ms-vscode-remote.remote-ssh-edit
  ]
  #? Theme shared across all profiles
  ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
    {
      #https://open-vsx.org/extension/lukinco/lukin-vscode-theme
      name = "lukin-vscode-theme";
      publisher = "lukinco";
      version = "0.1.5";
      hash = "sha256-T6yCPCy2AprDqNTJk2ucN2EsCrODn4j/1oldSnQNigU=";
    }
  ];

  defaultOnlyExtensions = with pkgs.vscode-extensions; [
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

    #* Git
    donjayamanne.githistory
    github.vscode-pull-request-github
  ];

  # { <name>-nixpkgs-extensions; <name>-marketplace-extensions } -> HM profile
  profileOf = name: e: {
    extensions =
      e."${name}-nixpkgs-extensions"
      ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace
      e."${name}-marketplace-extensions";
  };

  # Profile name -> ext-set attr prefix (UML.nix uses an uppercase prefix).
  langProfiles = {
    sql = profileOf "sql" sql;
    cpp = profileOf "cpp" cpp;
    zig = profileOf "zig" zig;
    nix = profileOf "nix" nixX;
    uml = profileOf "UML" umlx;
    java = profileOf "java" java;
    rust = profileOf "rust" rust;
    dart = profileOf "dart" dartX;
    go = profileOf "golang" golang;
    prolog = profileOf "prolog" prolog;
    kotlin = profileOf "kotlin" kotlinX;
    python = profileOf "python" pythonX;
    lua = profileOf "lua" luaX;
  };
  # Every profile: shared core + its own extensions, and the SAME settingsJson
  # store path. HM passes a store path to userSettings through verbatim
  # (mkVscodeModule.nix), so the JSONC comments survive and all profiles share
  # byte-identical settings.
  profiles = lib.mapAttrs (_: p: {
    extensions = sharedExtensions ++ p.extensions;
    userSettings = settingsJson;
  }) ({
    default.extensions =
      defaultOnlyExtensions
      ++ generalX.general-nixpkgs-extensions
      ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace
      generalX.general-marketplace-extensions;

    # Dedicated markdown/diagram profile: mermaid + plantuml only. The
    # extensions also stay in the profiles they came from (default, sql, uml).
    markdown.extensions = with pkgs.vscode-extensions;
      [
        bierner.markdown-mermaid
        jebbs.plantuml
      ]
      ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
        {
          #https://open-vsx.org/api/bpruitt-goddard/mermaid-markdown-syntax-highlighting
          name = "mermaid-markdown-syntax-highlighting";
          publisher = "bpruitt-goddard";
          version = "1.6.6";
          hash = "sha256-1WwjGaYNHN6axlprjznF1S8BB4cQLnNFXqi7doQZjrQ=";
        }
      ];
  } // langProfiles);
in {
  config = lib.mkIf config.dev.editors.vscodium.enable {
    # The same tools neovim gets, so an editor never depends on which Langs/
    # module happens to be imported. The editor itself is installed by
    # home-manager below.
    environment.systemPackages = dev.allPackages;

    # VSCodium with per-language extension profiles, managed by home-manager.
    # Scoping: everything inside home-manager.users.<user> is evaluated by
    # home-manager, so programs.vscodium here is HM's option.
    #
    # NOTE: settings.json is a read-only store symlink in every profile —
    # change Dev/IDEs/vscode_config.jsonc and rebuild instead of editing in
    # the VSCodium UI. Also close VSCodium before `nixos-rebuild switch`:
    # HM registers profiles in globalStorage/storage.json, which VSCodium
    # rewrites from RAM on exit.
    home-manager.users.${config.identity.username} = {
      home.stateVersion = "26.05";

      programs.vscodium = {
        enable = true;
        package = pkgs.vscodium;
        mutableExtensionsDir = false;
        inherit profiles;
      };
    };
  };
}

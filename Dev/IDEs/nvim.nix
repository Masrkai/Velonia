# IDEs/nvim.nix
{
  pkgs,
  lib,
  config,
  ...
}: let
  dev = import ../lib.nix {inherit pkgs lib;};

  # ---------------------------------------------------------------------------
  # nixvim pin (no flakes).
  #
  # The branch MUST match your NixOS release or option names will not line up.
  # Pin by tarball + hash so the result is reproducible and cannot drift.
  #
  # First build: leave `sha256 = lib.fakeSha256;`, run the rebuild once, copy the
  # "got: sha256-..." value Nix prints into the field below.
  # ---------------------------------------------------------------------------

  # nixvimSrc = builtins.fetchTarball {
  #   url = "https://github.com/nix-community/nixvim/archive/refs/heads/nixos-26.05.tar.gz";
  #   sha256 = lib.fakeSha256;
  # };

  nixvimSrc = import (builtins.fetchGit {
    url = "https://github.com/nix-community/nixvim";
    # ref = "nixos-25.11"; # match your NixOS version
    # optionally pin a specific commit:
    # get latest by running the following command
    # git ls-remote https://github.com/nix-community/nixvim refs/heads/nixos-25.11
    rev = "b8f76bf5751835647538ef8784e4e6ee8deb8f95";
  });
in {
  imports = [(import nixvimSrc).nixosModules.nixvim];

  config = lib.mkIf config.dev.editors.neovim.enable {
    programs.nixvim = {
      enable = true;
      defaultEditor = lib.mkDefault false;

      extraConfigLua = builtins.readFile ./nvim.lua;

      # =======================================================================
      # APPEARANCE
      # =======================================================================
      colorschemes.tokyonight = {
        enable = true;
        settings = {
          transparent = true;
          styles = {
            sidebars = "transparent";
            floats = "transparent";
          };
        };
      };

      opts = {
        number = true;
        relativenumber = false;

        tabstop = 2;
        shiftwidth = 2;
        expandtab = true;
        smartindent = true;

        ignorecase = true;
        smartcase = true;
        hlsearch = true;
        incsearch = true;

        wrap = false;
        scrolloff = 8;
        splitright = true;
        splitbelow = true;

        updatetime = 250;
        termguicolors = true;
        signcolumn = "yes";
        cursorline = true;

        clipboard = "unnamedplus";
        mouse = "a";
      };

      # =======================================================================
      # UI / NAVIGATION / PREVIEWING
      # =======================================================================
      plugins.neo-tree = {
        enable = true;
        settings = {
          close_if_last_window = true;
          window = {
            position = "right";
            width = 35;
          };
          filesystem = {
            filtered_items = {
              visible = true;
              hide_gitignored = false;
            };
            follow_current_file = {
              enabled = true;
              leave_dirs_open = true;
            };
          };
        };
      };

      plugins.bufferline = {
        enable = true;
        settings.options = {
          diagnostics = "nvim_lsp";
          show_buffer_close_icons = true;
          show_close_icon = false;
          separator_style = "thin";
        };
      };

      plugins.lualine = {
        enable = true;
        settings.options = {
          theme = "tokyonight"; # was "gruvbox": mismatched the colorscheme
          globalstatus = true;
        };
      };

      plugins.web-devicons.enable = true;
      plugins.rainbow-delimiters.enable = true;
      plugins.which-key.enable = true;
      plugins.nvim-autopairs.enable = true;

      plugins.indent-blankline = {
        enable = true;
        settings.scope.enabled = true;
      };

      plugins.markdown-preview.enable = true;
      plugins.visual-multi.enable = true;

      # =======================================================================
      # SYNTAX
      #
      # nixvim installs grammars through Nix. The old `ensureInstalled` key is
      # nvim-treesitter's runtime installer and does nothing here. Grammars are
      # derived from the registry filetypes instead, so a language you add to
      # the registry gets highlighting automatically.
      # =======================================================================
      plugins.treesitter = {
        enable = true;
        settings = {
          highlight.enable = true;
          indent.enable = true;
        };
        grammarPackages = with pkgs.vimPlugins.nvim-treesitter.builtGrammars; [
          nix
          python
          c
          cpp
          rust
          dart
          zig
          bash
          lua
          json
          yaml
          toml
          markdown
          markdown_inline
          cmake
          sql
          go
          java
          kotlin
          typescript
          javascript
          tsx
          html
          css
        ];
      };

      # =======================================================================
      # FUZZY FINDER
      # =======================================================================
      plugins.telescope = {
        enable = true;
        extensions.fzf-native.enable = true;
      };

      # =======================================================================
      # GIT
      # =======================================================================
      plugins.gitsigns = {
        enable = true;
        settings = {
          current_line_blame = true;
          current_line_blame_opts.delay = 500;
        };
      };
      plugins.neogit = {
        enable = true;
        settings.integrations.diffview = true;
      };
      plugins.diffview.enable = true;

      # =======================================================================
      # LSP  (generated from dev/registry.nix, so it matches VSCodium)
      # =======================================================================
      plugins.lsp = {
        enable = true;
        servers =
          lib.genAttrs dev.nvimLspServers (_: {enable = true;})
          # per-server overrides declared in the registry (e.g. nixd formatter)
          // lib.mapAttrs (_: v: {enable = true;} // v) dev.nvimLspSettings
          // {
            # Use the system toolchain instead of nixvim bundling rustc/cargo.
            rust_analyzer = {
              enable = true;
              installRustc = false;
              installCargo = false;
              settings.restartServerOnConfigChange = true;
            };
            # Deliberately NO --compile-commands-dir. The old value resolved to
            # the Nix store path of this module. clangd finds
            # compile_commands.json by walking up from the open file, which is
            # what you want per-project.
            clangd.enable = true;
          };
      };

      # =======================================================================
      # FORMATTING  (generated from the registry)
      # `format_on_save` previously appeared twice, which is a duplicate
      # attribute error in Nix. It is now defined once, disabled, matching
      # VSCodium's per-language formatOnSave = false.
      # =======================================================================
      plugins.conform-nvim = {
        enable = true;
        settings = {
          format_on_save = null;
          formatters_by_ft = dev.nvimFormattersByFt;
        };
      };

      # =======================================================================
      # LINTING  (generated from the registry)
      # =======================================================================
      plugins.lint = {
        enable = true;
        lintersByFt = dev.nvimLintersByFt // {nix = ["nix"];};
      };

      # =======================================================================
      # COMPLETION
      # =======================================================================
      plugins.luasnip.enable = true;
      plugins.cmp = {
        enable = true;
        settings = {
          sources = [
            {name = "nvim_lsp";}
            {name = "luasnip";}
            {name = "path";}
            {name = "buffer";}
          ];
          mapping = {
            "<Tab>" = "cmp.mapping.select_next_item()";
            "<S-Tab>" = "cmp.mapping.select_prev_item()";
            "<CR>" = "cmp.mapping.confirm({ select = true })";
            "<C-Space>" = "cmp.mapping.complete()";
          };
        };
      };

      # =======================================================================
      # COMMENT HIGHLIGHTING  (mirrors the Better Comments tags in VSCodium)
      # =======================================================================
      plugins.todo-comments = {
        enable = true;
        settings.keywords = {
          FIX = {
            icon = " ";
            color = "#FF2D00";
            alt = ["!" "FIXME" "BUG" "FIXIT" "ISSUE"];
          };
          TODO = {
            icon = " ";
            color = "#FF8C00";
          };
          HACK = {
            icon = " ";
            color = "#F4CE14";
            alt = [">"];
          };
          WARN = {
            icon = " ";
            color = "#F4CE14";
            alt = ["WARNING" "XXX"];
          };
          PERF = {
            icon = " ";
            color = "#98C379";
            alt = ["*" "OPTIM" "PERFORMANCE" "OPTIMIZE"];
          };
          NOTE = {
            icon = " ";
            color = "#3498DB";
            alt = ["?" "INFO"];
          };
          TEST = {
            icon = "⏲ ";
            color = "#8C6A5D";
            alt = ["-" "TESTING" "PASSED" "FAILED"];
          };
        };
      };

      # =======================================================================
      # Keymaps / Shortcuts
      # =======================================================================

      keymaps = [
        {
          mode = ["n" "v"];
          key = "<leader>f";
          action.__raw = ''
            function() require("conform").format({ async = true, lsp_fallback = true }) end
          '';
          options.desc = "Format buffer";
        }
      ];

      # =======================================================================
      # TOOLS ON PATH  (the SAME packages VSCodium points at)
      # =======================================================================
      extraPackages = dev.allPackages;
    };
  };
}

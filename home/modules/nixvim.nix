# home/modules/nixvim.nix
{ pkgs, hostName, colorScheme, lib ? pkgs.lib, ... }:
let
  # nix-colors provides Base16 colors as "RRGGBB" (no '#').
  # base16-nvim expects "#RRGGBB". Convert all palette values.
  withHash = lib.mapAttrs (_: v: if lib.hasPrefix "#" v then v else "#${v}") colorScheme.palette;
in
{
  programs.nixvim = {
    enable = true;     # Manage Neovim via nixvim (Home Manager)
    viAlias = true;    # `vi` launches Neovim
    vimAlias = true;   # `vim` launches Neovim

    # -----------------------------
    # Leader keys (set before maps)
    # -----------------------------
    globals = {
      mapleader = " ";       # <leader> = Space
      maplocalleader = " ";  # <localleader> = Space (for plugin-local maps)
    };

    # ---------------------------------------------
    # Look & feel — unify theme from flake's scheme
    # ---------------------------------------------
    colorschemes.base16 = {
      enable = true;
      colorscheme = withHash;    # pass "#RRGGBB" palette (base00..base0F)
      # Optional plugin integrations:
      # settings = { telescope = true; indentblankline = true; cmp = true; nvimtree = true; };
    };

    # -------------------------------
    # Core options (editor behaviour)
    # -------------------------------
    opts = {
      number = true;            # show line numbers
      relativenumber = true;    # relative line numbers for motions
      tabstop = 2;              # visual width of a tab
      shiftwidth = 2;           # indentation width
      expandtab = true;         # insert spaces instead of tabs
      smartindent = true;       # smart autoindent
      wrap = false;             # no soft-wrapping
      cursorline = true;        # highlight current line
      termguicolors = true;     # 24-bit colors
      signcolumn = "yes";       # always show sign column (LSP, git)
      updatetime = 250;         # faster CursorHold/autocmds
      timeoutlen = 400;         # which-key/Telescope feel snappy

      # Folding defaults tuned for nvim-ufo
      foldcolumn = "1";         # dedicated fold column
      foldlevel = 99;           # don't start collapsed
      foldlevelstart = 99;      # same on startup
      foldenable = true;        # enable folding engine
    };

    # -----------------------------
    # Keymaps (normal-mode only)
    # -----------------------------
    keymaps = [
      # Telescope (fuzzy finding / search)
      { mode = "n"; key = "<leader>ff"; action = "<cmd>Telescope find_files<CR>"; }  # find files
      { mode = "n"; key = "<leader>fg"; action = "<cmd>Telescope live_grep<CR>"; }   # grep project
      { mode = "n"; key = "<leader>fb"; action = "<cmd>Telescope buffers<CR>"; }     # switch buffer
      { mode = "n"; key = "<leader>fh"; action = "<cmd>Telescope help_tags<CR>"; }   # search help

      # File tree
      { mode = "n"; key = "<leader>e";  action = "<cmd>NvimTreeToggle<CR>"; }        # toggle explorer

      # LSP UX
      { mode = "n"; key = "gd";         action = "<cmd>lua vim.lsp.buf.definition()<CR>"; }     # goto def
      { mode = "n"; key = "gr";         action = "<cmd>Telescope lsp_references<CR>"; }         # references
      { mode = "n"; key = "K";          action = "<cmd>lua vim.lsp.buf.hover()<CR>"; }          # hover docs
      { mode = "n"; key = "<leader>rn"; action = "<cmd>lua vim.lsp.buf.rename()<CR>"; }         # rename symbol
      { mode = "n"; key = "<leader>ca"; action = "<cmd>lua vim.lsp.buf.code_action()<CR>"; }    # code actions

      # Formatting via conform.nvim (per filetype tools, with LSP fallback)
      { mode = "n"; key = "<leader>f";  action = "<cmd>lua require('conform').format({ async = true })<CR>"; }

      # Folding helpers (nvim-ufo; native zR/zM also exist)
      { mode = "n"; key = "<leader>zR"; action = "<cmd>lua require('ufo').openAllFolds()<CR>"; }
      { mode = "n"; key = "<leader>zM"; action = "<cmd>lua require('ufo').closeAllFolds()<CR>"; }
      { mode = "n"; key = "zr";         action = "<cmd>lua require('ufo').openFoldsExceptKinds()<CR>"; }
      { mode = "n"; key = "zm";         action = "<cmd>lua require('ufo').closeFoldsWith()<CR>"; }
    ];

    # --------------
    # Plugins stack
    # --------------
    plugins = {
      web-devicons.enable = true;  # filetype icons (silences deprecation warnings)
      indent-blankline.enable = true;  # indentation guides (ibl in newer pins)
      lualine.enable = true;       # statusline
      telescope.enable = true;     # fuzzy finder
      nvim-tree.enable = true;     # file explorer
      nvim-autopairs.enable = true;# auto close brackets/quotes
      colorizer.enable = true;     # inline color highlights (CSS hex, etc.)

      # Syntax highlighting & better AST info
      treesitter = {
        enable = true;
        settings = {
          ensure_installed = [
            "nix" "lua" "python" "rust" "bash" "markdown" "json" "yaml" "tsx" "html" "css"
          ];
          indent = { enable = true; };     # treesitter-based indent
          highlight = { enable = true; };  # treesitter highlights
        };
      };

      # Smart, fast folding powered by Treesitter/indent providers
      "nvim-ufo" = {
        enable = true;
        settings = {
          open_fold_hl_timeout = 0;  # no highlight delay when opening folds
          # Prefer Treesitter folds, fall back to indent if unsupported
          provider_selector.__raw = ''
            function(_, _, _)
              return {"treesitter", "indent"}
            end
          '';
        };
      };

      # Built-in LSP client configuration
      lsp = {
        enable = true;
        servers = {
          # Nix language server (nixd) with flake-aware context
          nixd = {
            enable = true;
            settings = {
              nixd = {
                formatting.command = [ "nixpkgs-fmt" ];  # formatter choice
                # Evaluate nixpkgs from flake input for completions
                nixpkgs.expr = ''(import (builtins.getFlake ".").inputs.nixpkgs { })'';
                # Offer NixOS options for the current host
                options.nixos.expr =
                  ''(builtins.getFlake ".").nixosConfigurations.${hostName}.options'';
                # Offer Home Manager option schema under that host
                options.home_manager_users.expr =
                  ''(builtins.getFlake ".").nixosConfigurations.${hostName}.options.home-manager.users.type.getSubOptions []'';
                diagnostics.suppress = [ "unused_binding" "unused_with" ]; # reduce noise
              };
            };
          };

          # Common language servers
          lua_ls.enable = true;    # Lua (Neovim config/dev)
          pyright.enable = true;   # Python
          ts_ls.enable = true;     # TypeScript/JavaScript (if this fails on older pins, use tsserver)
          bashls.enable = true;    # Bash
          html.enable = true;      # HTML
          cssls.enable = true;     # CSS
          jsonls.enable = true;    # JSON
          yamlls.enable = true;    # YAML

          # Rust with optional toolchain installs managed by nixvim
          rust_analyzer = {
            enable = true;
            installCargo = true;   # ensure cargo exists for LSP features
            installRustc = true;   # ensure rustc exists for LSP features
          };
        };
      };

      # Completion stack (nvim-cmp)
      cmp = {
        enable = true;
        settings = {
          snippet = { expand = "luasnip"; };  # use LuaSnip for snippets
          sources = [
            { name = "nvim_lsp"; }  # LSP completions
            { name = "luasnip"; }   # snippet completions
            { name = "path"; }      # filesystem paths
            { name = "buffer"; }    # words in current buffers
          ];
          # Minimal, ergonomic mappings for completion
          mapping = {
            "<C-Space>" = "cmp.mapping.complete()";
            "<CR>"      = "cmp.mapping.confirm({ select = true })";
            "<Tab>"     = "cmp.mapping.select_next_item()";
            "<S-Tab>"   = "cmp.mapping.select_prev_item()";
            "<C-b>"     = "cmp.mapping.scroll_docs(-4)";
            "<C-f>"     = "cmp.mapping.scroll_docs(4)";
            "<C-e>"     = "cmp.mapping.close()";
          };
        };
      };

      # Snippet engine used by nvim-cmp
      luasnip.enable = true;

      # Formatting orchestrator (runs external tools per filetype)
      conform-nvim = {
        enable = true;
        settings = {
          # Map filetypes to formatters (tries in order; falls back to LSP if allowed)
          formatters_by_ft = {
            nix = [ "nixpkgs-fmt" ];
            lua = [ "stylua" ];
            python = [ "black" ];
            rust = [ "rustfmt" ];
            sh = [ "shfmt" ];
            javascript = [ "prettierd" "prettier" ];
            typescript = [ "prettierd" "prettier" ];
            json = [ "prettierd" "prettier" ];
            yaml = [ "prettierd" "prettier" ];
            markdown = [ "prettierd" "prettier" ];
          };
          format_on_save = {
            lspFallback = true; # use LSP formatter if no external one is configured
            timeoutMs = 1500;   # avoid hanging on slow tools
          };
        };
      };
    };

    # --------------------------------------
    # External tools binaries used by Neovim
    # --------------------------------------
    extraPackages = with pkgs; [
      # LSP and formatters
      nixd
      nixpkgs-fmt
      stylua
      black
      rustfmt
      shfmt
      nodePackages.prettier
      prettierd

      # Finders used by Telescope
      ripgrep
      fd
    ];

    # ---------------------------------------------------------
    # Extra Vim plugins not covered by nixvim modules or pins
    # ---------------------------------------------------------
    extraPlugins = with pkgs.vimPlugins; [
      promise-async  # required by nvim-ufo (dependency)
    ];
  };
}


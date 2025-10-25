# home/modules/nixvim.nix
# =============================================================================
# Neovim via nixvim (Home Manager)
#
# Provides
#   • Base16 theme from Stylix (if present) or flake `colorScheme`
#   • LSP stack, Treesitter, Telescope (+ fzf-native extension), NvimTree
#   • Formatting via conform.nvim; completion via nvim-cmp + LuaSnip
#   • Persistent undo, clipboard=unnamedplus, predictable splits
# =============================================================================
{ pkgs, hostName, colorScheme, lib ? pkgs.lib, config, ... }:

let
  # Normalize hex to "#RRGGBB".
  withHash = v: if lib.hasPrefix "#" v then v else "#${v}";

  # Prefer Stylix palette when available; otherwise use flake `colorScheme`.
  paletteNoHash =
    if (config ? stylix) && (config.stylix ? colors) then
      config.stylix.colors
    else
      colorScheme.palette;

  palette = lib.mapAttrs (_: withHash) paletteNoHash;
in
{
  programs.nixvim = {
    enable   = true;
    viAlias  = true;
    vimAlias = true;

    # Leaders first.
    globals = {
      mapleader      = " ";
      maplocalleader = " ";
    };

    # Theme from Base16 palette.
    colorschemes.base16 = {
      enable      = true;
      colorscheme = palette;   # expects base00..base0F = "#RRGGBB"
    };

    # Core options.
    opts = {
      number         = true;
      relativenumber = true;
      cursorline     = true;
      signcolumn     = "yes";
      termguicolors  = true;
      scrolloff      = 4;
      wrap           = false;

      tabstop     = 2;
      shiftwidth  = 2;
      expandtab   = true;
      smartindent = true;

      updatetime = 250;
      timeoutlen = 400;

      splitbelow = true;
      splitright = true;

      clipboard = "unnamedplus";

      foldcolumn     = "1";
      foldlevel      = 99;
      foldlevelstart = 99;
      foldenable     = true;

      undofile = true;
      undodir  = "${config.xdg.stateHome}/nvim/undo";
    };

    # Keymaps (normal mode).
    keymaps = [
      { mode = "n"; key = "<leader>ff"; action = "<cmd>Telescope find_files<CR>"; }
      { mode = "n"; key = "<leader>fg"; action = "<cmd>Telescope live_grep<CR>"; }
      { mode = "n"; key = "<leader>fb"; action = "<cmd>Telescope buffers<CR>"; }
      { mode = "n"; key = "<leader>fh"; action = "<cmd>Telescope help_tags<CR>"; }
      { mode = "n"; key = "<leader>e";  action = "<cmd>NvimTreeToggle<CR>"; }

      { mode = "n"; key = "gd";         action = "<cmd>lua vim.lsp.buf.definition()<CR>"; }
      { mode = "n"; key = "gr";         action = "<cmd>Telescope lsp_references<CR>"; }
      { mode = "n"; key = "K";          action = "<cmd>lua vim.lsp.buf.hover()<CR>"; }
      { mode = "n"; key = "<leader>rn"; action = "<cmd>lua vim.lsp.buf.rename()<CR>"; }
      { mode = "n"; key = "<leader>ca"; action = "<cmd>lua vim.lsp.buf.code_action()<CR>"; }

      { mode = "n"; key = "<leader>f";  action = "<cmd>lua require('conform').format({ async = true })<CR>"; }

      { mode = "n"; key = "<leader>zR"; action = "<cmd>lua require('ufo').openAllFolds()<CR>"; }
      { mode = "n"; key = "<leader>zM"; action = "<cmd>lua require('ufo').closeAllFolds()<CR>"; }
      { mode = "n"; key = "zr";         action = "<cmd>lua require('ufo').openFoldsExceptKinds()<CR>"; }
      { mode = "n"; key = "zm";         action = "<cmd>lua require('ufo').closeFoldsWith()<CR>"; }
    ];

    # Plugins.
    plugins = {
      web-devicons.enable     = true;
      indent-blankline.enable = true;
      lualine.enable          = true;
      nvim-tree.enable        = true;
      nvim-autopairs.enable   = true;
      colorizer.enable        = true;
      which-key.enable        = true;

      # Telescope + fzf-native lives under extensions.
      telescope = {
        enable = true;
        extensions.fzf-native.enable = true;
      };

      treesitter = {
        enable = true;
        settings = {
          ensure_installed = [
            "nix" "lua" "python" "rust" "bash" "markdown" "json" "yaml" "tsx" "html" "css"
          ];
          indent    = { enable = true; };
          highlight = { enable = true; };
        };
      };

      "nvim-ufo" = {
        enable = true;
        settings = {
          open_fold_hl_timeout = 0;
          provider_selector.__raw = ''
            function(_, _, _)
              return {"treesitter", "indent"}
            end
          '';
        };
      };

      lsp = {
        enable = true;
        servers = {
          nixd = {
            enable = true;
            settings = {
              nixd = {
                formatting.command = [ "nixpkgs-fmt" ];
                nixpkgs.expr = ''(import (builtins.getFlake ".").inputs.nixpkgs { })'';
                options.nixos.expr =
                  ''(builtins.getFlake ".").nixosConfigurations.${hostName}.options'';
                options.home_manager_users.expr =
                  ''(builtins.getFlake ".").nixosConfigurations.${hostName}.options.home-manager.users.type.getSubOptions []'';
                diagnostics.suppress = [ "unused_binding" "unused_with" ];
              };
            };
          };

          lua_ls.enable  = true;
          pyright.enable = true;
          ts_ls.enable   = true;
          bashls.enable  = true;
          html.enable    = true;
          cssls.enable   = true;
          jsonls.enable  = true;
          yamlls.enable  = true;

          rust_analyzer = {
            enable       = true;
            installCargo = true;
            installRustc = true;
          };
        };
      };

      cmp = {
        enable = true;
        settings = {
          snippet = { expand = "luasnip"; };
          sources = [
            { name = "nvim_lsp"; }
            { name = "luasnip"; }
            { name = "path"; }
            { name = "buffer"; }
          ];
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

      luasnip.enable = true;

      conform-nvim = {
        enable = true;
        settings = {
          formatters_by_ft = {
            nix        = [ "nixpkgs-fmt" ];
            lua        = [ "stylua" ];
            python     = [ "black" ];
            rust       = [ "rustfmt" ];
            sh         = [ "shfmt" ];
            javascript = [ "prettierd" "prettier" ];
            typescript = [ "prettierd" "prettier" ];
            json       = [ "prettierd" "prettier" ];
            yaml       = [ "prettierd" "prettier" ];
            markdown   = [ "prettierd" "prettier" ];
          };
          format_on_save = {
            lspFallback = true;
            timeoutMs   = 1500;
          };
        };
      };
    };

    # External binaries.
    extraPackages = with pkgs; [
      nixd
      nixpkgs-fmt
      stylua
      black
      rustfmt
      shfmt
      nodePackages.prettier
      prettierd
      ripgrep
      fd
    ];

    # Extra Vim plugins not covered by nixvim modules.
    extraPlugins = with pkgs.vimPlugins; [
      promise-async  # dependency for nvim-ufo
    ];
  };
}




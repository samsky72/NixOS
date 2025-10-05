{ pkgs, hostName, ... }:
{
  programs.nixvim = {
    enable = true;
    viAlias = true;
    vimAlias = true;

    ########################################
    ## Look & feel
    ########################################
    colorschemes.tokyonight.enable = true;

    opts = {
      number = true;
      relativenumber = true;
      tabstop = 2;
      shiftwidth = 2;
      expandtab = true;
      smartindent = true;
      wrap = false;
      cursorline = true;
      termguicolors = true;
      signcolumn = "yes";
      updatetime = 250;
      timeoutlen = 400;
    };

    ########################################
    ## Keymaps (no desc)
    ########################################
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
    ];

    ########################################
    ## Plugins
    ########################################
    plugins = {
      # Explicit devicons (silences the deprecation warning)
      web-devicons.enable = true;
      indent-blankline.enable = true;
      lualine.enable = true;
      telescope.enable = true;
      nvim-tree.enable = true;
      nvim-autopairs.enable = true;
      colorizer.enable = true;
      treesitter = {
        enable = true;
        settings = {
          ensure_installed = [ "nix" "lua" "python" "rust" "bash" "markdown" "json" "yaml" "tsx" "html" "css" ];
          indent.enable = true;
          highlight.enable = true;
        };
      };

      # LSP
      lsp = {
        enable = true;
        servers = {
          nixd = {
            enable = true;
            settings = {
              nixd = {
                # Formatter
                formatting.command = [ "nixpkgs-fmt" ];

                # Evaluate nixpkgs from your flake input
                nixpkgs.expr = ''(import (builtins.getFlake ".").inputs.nixpkgs { })'';

                # NixOS options scope for your host (uses `hostName` passed via extraSpecialArgs)
                options.nixos.expr =
                  ''(builtins.getFlake ".").nixosConfigurations.${hostName}.options'';

                # Home Manager options scope under that host:
                # This pulls the *schema* under home-manager.users, which gives nixd rich HM completions.
                options.home_manager_users.expr =
                  ''(builtins.getFlake ".").nixosConfigurations.${hostName}.options.home-manager.users.type.getSubOptions []'';

                # (Optional) quiet down some noisy diags
                diagnostics.suppress = [ "unused_binding" "unused_with" ];
              };
            };
          };

          lua_ls.enable = true;
          pyright.enable = true;
          ts_ls.enable = true;          # <- renamed from tsserver/ts-ls
          bashls.enable = true;
          html.enable = true;
          cssls.enable = true;
          jsonls.enable = true;
          yamlls.enable = true;

          rust_analyzer = {
            enable = true;
            # Silence cargo/rustc warnings by letting Nixvim provide them:
            installCargo = true;
            installRustc = true;
            # (Optional) choose specific packages:
            # cargoPackage = pkgs.rust-bin.stable.latest.default;   # if you use rust-overlay
            # rustcPackage  = pkgs.rustc;
          };
        };
      };

      # Completion (nvim-cmp)
      cmp = {
        enable = true;
        settings = {
          snippet = { expand = "luasnip"; };
          sources = [
            { name = "nvim_lsp"; }
            { name = "buffer"; }
            { name = "path"; }
            { name = "luasnip"; }
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

      # Formatting (conform.nvim)
      conform-nvim = {
        enable = true;
        settings = {
          formatters_by_ft = {
            nix = [ "nixpkgs-fmt" ];
            lua = [ "stylua" ];
            python = [ "black" ];              # or ruff_format
            rust = [ "rustfmt" ];
            sh = [ "shfmt" ];
            javascript = [ "prettierd" "prettier" ];
            typescript = [ "prettierd" "prettier" ];
            json = [ "prettierd" "prettier" ];
            yaml = [ "prettierd" "prettier" ];
            markdown = [ "prettierd" "prettier" ];
          };
          format_on_save = { lspFallback = true; timeoutMs = 1500; };
        };
      };
    };

    ########################################
    ## Extra tools Neovim relies on
    ########################################
    extraPackages = with pkgs; [
      nixd
      nixpkgs-fmt
      stylua
      black
      rustfmt
      shfmt
      ripgrep
      fd
      nodePackages.prettier
      prettierd
    ];
  };
}

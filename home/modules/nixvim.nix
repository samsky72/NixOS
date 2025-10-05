# home/modules/nixvim.nix
{ pkgs, inputs, ... }:
{
  # Import nixvim's Home Manager module
  imports = [ inputs.nixvim.homeModules.nixvim ];

  programs.nixvim = {
    enable = true;
    viAlias = true;
    vimAlias = true;

    ########################################
    ## Look & feel
    ########################################
    colorschemes.catppuccin = {
      enable = true;
      flavour = "mocha";
    };

    opts = {
      number = true;
      relativenumber = true;
      mouse = "a";
      termguicolors = true;
      signcolumn = "yes";
      shiftwidth = 2;
      tabstop = 2;
      expandtab = true;
      updatetime = 300;
      timeoutlen = 500;
    };

    ########################################
    ## Plugins
    ########################################
    plugins = {
      # UI
      lualine.enable = true;
      which-key.enable = true;
      telescope.enable = true;

      # Treesitter
      treesitter = {
        enable = true;
        indent = true;
        folding = true;
      };

      # LSP setup
      lsp = {
        enable = true;
        servers = {
          nixd.enable = true;        # ✅ replaces nil_ls
          lua_ls.enable = true;
          pyright.enable = true;
          tsserver.enable = true;
          bashls.enable = true;
          html.enable = true;
          cssls.enable = true;
          jsonls.enable = true;
          yamlls.enable = true;
        };
      };

      # Completion
      cmp = {
        enable = true;
        autoEnableSources = true;
        sources = [
          { name = "nvim_lsp"; }
          { name = "buffer"; }
          { name = "path"; }
          { name = "luasnip"; }
        ];
      };
      luasnip.enable = true;

      # Formatting
      conform-nvim = {
        enable = true;
        settings = {
          formatters_by_ft = {
            nix = [ "nixpkgs-fmt" ];
            lua = [ "stylua" ];
            python = [ "ruff_format" "ruff_organize_imports" ];
            javascript = [ "prettierd" "prettier" ];
            typescript = [ "prettierd" "prettier" ];
            json = [ "prettierd" "prettier" ];
            yaml = [ "prettierd" "prettier" ];
            markdown = [ "prettierd" "prettier" ];
            sh = [ "shfmt" ];
          };
          format_on_save = { lspFallback = true; timeoutMs = 1500; };
        };
      };

      gitsigns.enable = true;
      noice.enable = true;
      notify.enable = true;
    };

    ########################################
    ## Keymaps
    ########################################
    globals.mapleader = " ";
    keymaps = [
      { mode = "n"; key = "<leader>ff"; action = "<cmd>Telescope find_files<CR>"; desc = "Find files"; }
      { mode = "n"; key = "<leader>fg"; action = "<cmd>Telescope live_grep<CR>";  desc = "Live grep"; }
      { mode = "n"; key = "<leader>fb"; action = "<cmd>Telescope buffers<CR>";    desc = "Buffers"; }
      { mode = "n"; key = "<leader>fh"; action = "<cmd>Telescope help_tags<CR>";  desc = "Help"; }

      { mode = "n"; key = "gd"; action = "<cmd>lua vim.lsp.buf.definition()<CR>"; desc = "Goto def"; }
      { mode = "n"; key = "gr"; action = "<cmd>Telescope lsp_references<CR>"; desc = "References"; }
      { mode = "n"; key = "K";  action = "<cmd>lua vim.lsp.buf.hover()<CR>"; desc = "Hover"; }
      { mode = "n"; key = "<leader>rn"; action = "<cmd>lua vim.lsp.buf.rename()<CR>"; desc = "Rename"; }
      { mode = "n"; key = "<leader>ca"; action = "<cmd>lua vim.lsp.buf.code_action()<CR>"; desc = "Code action"; }
      { mode = "n"; key = "<leader>f"; action = "<cmd>lua require('conform').format({ async = true })<CR>"; desc = "Format"; }
    ];

    ########################################
    ## External tools
    ########################################
    extraPackages = with pkgs; [
      nixd
      nixpkgs-fmt
      stylua
      ruff
      ruff-lsp
      nodePackages.prettier
      prettierd
      shfmt
      ripgrep
      fd
    ];
  };
}

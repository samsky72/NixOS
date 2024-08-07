# NixVim configurations
{ config, userName, ... }: {

  # NixVim home-manager configuration.
  home-manager.users.${userName}.programs.nixvim = {
    
    enable = true;

    #NixVim options.
    opts = {
      expandtab = true;                                                                     # Replace Tab to spaces.
      number = true;                                                                        # Enable numbers.
      shiftwidth = 2;                                                                       # Shift width 2 symbols.
      smartindent = true;
      tabstop = 2;
    };

    plugins = {

      # Complete plugins.
      cmp = {
        autoEnableSources = true;
        enable = true;
        settings = {
          mapping = {
            "<Tab>" = "cmp.mapping(cmp.mapping.select_next_item(), {'i', 's'})";
            "<CR>" = "cmp.mapping.confirm({ select = true })";
            "<C-Space>" = "cmp.mapping.complete()";
            "<C-j>" = "cmp.mapping.select_next_item()";
            "<C-k>" = "cmp.mapping.select_prev_item()";
          };
          sources = [
            { name = "buffer"; }
            { name = "luasnip"; }
            { name = "nvim_lsp"; }
            { name = "path"; }
          ];
        };
      };

      # Indent line plugins.
      indent-blankline.enable = true;

      # LSP servers plugins.
      lsp = {
        enable = true;
        servers = {
          nixd.enable = true;
        };
      };

      # LUA snip plugins.
      luasnip.enable= true;

      # Auto pairs plugins.
      nvim-autopairs.enable = true;
    };
  };

  # NixVim configuration.
  programs.nixvim = {
    enable = true;
  };
}


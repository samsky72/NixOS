# NixVim configurations
{ config, userName, ... }: {

  # NixVim home-manager configuration.
  home-manager.users.${userName}.programs.nixvim = {
#  programs.nixvim = {   
    enable = true;

    #NixVim options.
    opts = {
      cursorline = true;
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
            "<S-Tab>" = "cmp.mapping(cmp.mapping.select_prev_item(), {'i', 's'})";
            "<CR>" = "cmp.mapping.confirm({ select = true })";
            "<C-Space>" = "cmp.mapping.complete()";
            "<C-j>" = "cmp.mapping.select_next_item()";
            "<C-k>" = "cmp.mapping.select_prev_item()";
          };   

          sources = [
            { name = "buffer"; }
            { name = "luasnip"; }
            { name = "nvim_lsp"; }
            { name = "nvim_lua"; }
            { name = "path"; }
          ];
        };
      };
      
      cmp-treesitter.enable = true;

      # Indent line plugins.
      indent-blankline.enable = true;

      # LSP servers plugins.
      lsp = {
        enable = true;
        servers = {
          nixd = {
            enable = true;
            settings = {
              nixpkgs = { 
                expr = "import <nixpkgs> { }";
              };
              options = {
                flake_parts = {
                  expr = ''let flake = builtins.getFlake ("/home/samsky/NixOS"); in flake.debug.options // flake.currentSystem.options'';
                };
                home_manager = {
                  expr = ''(builtins.getFlake "/home/samsky/NixOS").homeConfigurations.${userName}.options'';
                };
                nixos = {
                  expr = ''(builtins.getFlake "/home/samsky/NixOS").nixosConfigurations.hostname.options'';
                };
              };
            };
          };
        };
      };

      # LUA snip plugins.
      luasnip = {
        enable= true;
        fromVscode = [ ];
      };

      # Auto pairs plugins.
      nvim-autopairs.enable = true;

      # Treesitter plugins.
      treesitter.enable = true;
    };
  };

  #NixVim configuration.
  programs.nixvim = {
    enable = true;                      # Define nixvim system wide.
    viAlias = true;                     # Define vi alias.
    vimAlias = true;                    # Define vim alias.
  };
}


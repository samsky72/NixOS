# Neovim configuration.
{ config, pkgs, ... }:
let
  user = "samsky";
in {
  environment = {
    sessionVariables.EDITOR="nvim";
    systemPackages = with pkgs; [neovim];
  };
  home-manager.users.${user}.programs.neovim = {
    enable = true;
    extraConfig = ''
      set number
      set termguicolors
      inoremap <expr> <CR> pumvisible() ? "\<C-Y>" : "\<CR>"
    '';
    plugins = with pkgs.vimPlugins; [ 
      coc-nvim
      coc-snippets
      coc-vimlsp
      colorizer
      fugitive
      indentLine
      nerdtree
      pywal-nvim
      vim-addon-nix
      vim-nix
    ]; 
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
  };    
  programs.neovim = {
    enable = true;
    withNodeJs = true;
    withPython3 = true;
    withRuby = true;
  };
}

# home/users/${defaultUser}.nix
{ inputs, defaultUser, ... }: {

  ##########################################
  ## Home Manager - User Profile
  ##########################################
  ##
  ## This file defines the per-user Home Manager configuration.
  ## It imports shared user modules (terminal, editor, git, etc.)
  ## and integrates external inputs such as `nixvim`’s Home module.
  ##
  ## Parameters:
  ## - `inputs`: flake inputs (including nixvim)
  ## - `defaultUser`: dynamically passed from flake.nix
  ##########################################
  
  # Make NUR available to Home Manager's pkgs
  nixpkgs.overlays = [ inputs.nur.overlays.default ];

  imports = [
    ##########################################
    ## Core Home Modules
    ##########################################
    ../modules/xdg.nix         # XDG user directories (cache, config, data)
    ../modules/git.nix         # Global git identity and settings
    ../modules/kitty.nix       # Kitty terminal configuration
    ../modules/hyprland.nix    # Hyprland (Wayland compositor)
    ../modules/nixvim.nix      # Neovim configuration (via nixvim)
    
    ##########################################
    ## External Home Modules
    ##########################################
    inputs.nixvim.homeModules.nixvim # Import nixvim’s Home Manager integration
  ];

  ##########################################
  ## Basic User Definition
  ##########################################
  home = {
    username = defaultUser;
    homeDirectory = "/home/${defaultUser}";
  };
}


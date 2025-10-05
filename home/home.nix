# home/home.nix
{ defaultUser, stateVersion, ... }: {

  ##############################################
  ## Home Manager Configuration (per-user base)
  ##############################################
  ##
  ## This file defines the core structure of your Home Manager setup.
  ## It imports shared modules (e.g. git, kitty, nixvim, hyprland)
  ## and the user-specific configuration under `home/users/${defaultUser}.nix`.
  ##
  ## Parameters:
  ## - `defaultUser`: passed from flake.nix to select the active user
  ## - `stateVersion`: locks Home Manager behavior across upgrades
  ##############################################

  imports = [
    ##########################################
    ## Core user modules
    ##########################################
    ./modules/xdg.nix        # XDG paths and user directories
    ./modules/git.nix        # Git identity and defaults
    ./modules/kitty.nix      # Kitty terminal configuration
    ./modules/nixvim.nix     # NixVim setup (via Home Manager)
    ./modules/hyprland.nix   # Hyprland compositor (Wayland)
    ./modules/firefox.nix

    ##########################################
    ## Per-user configuration
    ##########################################
    ./users/${defaultUser}.nix
  ];

  ##############################################
  ## Home Manager State Version
  ##############################################
  ##
  ## Ensures compatibility across updates by locking
  ## the Home Manager state to your chosen version.
  ##############################################
  home.stateVersion = stateVersion;
}


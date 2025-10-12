# home/users/samsky/home.nix
{ stateVersion, ... }:

{
  ##############################################
  ## My Home Manager configuration (user: samsky)
  ##############################################

  # I set my identity and home path
  home.username = "samsky";
  home.homeDirectory = "/home/samsky";

  # I lock my HM state for stable upgrades
  home.stateVersion = stateVersion;

  # I import my shared user modules from ../../modules
  imports = [
    ../../modules/xdg.nix        # I manage XDG paths and user directories
    ../../modules/git.nix        # I set my Git identity and defaults
    ../../modules/kitty.nix      # I configure Kitty terminal
    ../../modules/nixvim.nix     # I configure Neovim via Home Manager
    ../../modules/hyprland.nix   # I enable Hyprland compositor (Wayland)
    ../../modules/firefox.nix    # I tune Firefox
    ../../modules/waybar.nix     # I configure Waybar
    ../../modules/zsh.nix        # I configure zsh
    ../../modules/stylix-targets.nix
    ../../modules/mpv-vapoursynth.nix
  ];
}


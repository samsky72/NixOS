# home/users/samsky/home.nix
{ config, lib, pkgs, stateVersion, hostName, ... }:

{
  ##############################################
  ## Home Manager configuration (user: samsky)
  ##############################################

  # User identity and home path
  home.username = "samsky";
  home.homeDirectory = "/home/samsky";

  # Lock Home Manager state for stable upgrades
  home.stateVersion = stateVersion;

  # Import shared user modules; append host-specific monitors when on Zephyrus
  imports =
    [
      ../../modules/xdg.nix              # Manage XDG paths and user directories
      ../../modules/git.nix              # Set Git identity and defaults
      ../../modules/kitty.nix            # Configure Kitty terminal
      ../../modules/nixvim.nix           # Configure Neovim via Home Manager
      ../../modules/hyprland.nix         # Enable Hyprland compositor (Wayland) — generic (no monitors)
      ../../modules/firefox.nix          # Tune Firefox
      ../../modules/waybar.nix           # Configure Waybar
      ../../modules/zsh.nix              # Configure Zsh (HM-native options only)
      ../../modules/stylix-targets.nix   # Set Stylix targets (GTK/Qt, etc.)
      ../../modules/mpv-vapoursynth.nix  # Enable mpv + VapourSynth (interpolation)
      ../../modules/pentest.nix          # Install pentest toolset
      ../../modules/udiskie.nix          # Autostart udiskie for automounting
      ../../modules/thunar.nix           # Configure Thunar + plugins
      ../../modules/kdeconnect.nix       # Enable KDE Connect integration
      ../../modules/qview.nix            # Install qView image viewer
      ../../modules/mako.nix             # Configure Mako notifications (Stylix-integrated)
    ]
    ++ lib.optionals (hostName == "zephyrus") [
      # Hardware-specific monitor mappings for this host
      ../../../hosts/zephyrus/hm/hypr-monitors.nix
    ];

  # Per-user environment variables can be added here if needed
  # home.sessionVariables = { };
}


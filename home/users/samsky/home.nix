# home/users/samsky/home.nix
{ config, lib, pkgs, stateVersion, hostName, ... }:

{
  ##############################################
  ## My Home Manager configuration (user: samsky)
  ##############################################

  # I set my identity and home path
  home.username = "samsky";
  home.homeDirectory = "/home/samsky";

  # I lock my HM state for stable upgrades
  home.stateVersion = stateVersion;

  # I import my shared user modules; I append host-specific monitors when on Zephyrus
  imports =
    [
      ../../modules/xdg.nix              # I manage XDG paths and user directories
      ../../modules/git.nix              # I set my Git identity and defaults
      ../../modules/kitty.nix            # I configure Kitty terminal
      ../../modules/nixvim.nix           # I configure Neovim via Home Manager
      ../../modules/hyprland.nix         # I enable Hyprland compositor (Wayland) — generic (no monitors)
      ../../modules/firefox.nix          # I tune Firefox
      ../../modules/waybar.nix           # I configure Waybar
      ../../modules/zsh.nix              # I configure Zsh (HM-native options only)
      ../../modules/stylix-targets.nix   # I set Stylix targets (GTK/Qt, etc.)
      ../../modules/mpv-vapoursynth.nix  # I enable mpv + VapourSynth (interpolation)
      ../../modules/pentest.nix          # I install my pentest toolset
      ../../modules/udiskie.nix          # I autostart udiskie for automounting
      ../../modules/thunar.nix           # I configure Thunar + plugins
      ../../modules/kdeconnect.nix
      ../../modules/kde-integration.nix
    ]
    ++ lib.optionals (hostName == "zephyrus") [
      # I keep hardware-specific monitor mappings separate per host
      ../../../hosts/zephyrus/hm/hypr-monitors.nix
    ];

  # I can add per-user environment variables here if needed
  # home.sessionVariables = { };

}


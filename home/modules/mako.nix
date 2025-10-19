# =============================================================================
# Mako — Wayland Notification Daemon (Stylix-integrated)
#
# Description:
#   • Provides desktop notifications (freedesktop.org / notify-send)
#   • Inherits palette and fonts from Stylix
#   • Tuned for Hyprland; started as a Home Manager user service
#
# Notes:
#   • Mako expects hyphen-separated option keys (e.g., border-radius)
#   • Leaving `output` unset makes notifications follow the focused output
#   • `services.mako.enable = true;` runs a user service; no Hyprland exec-once
# =============================================================================
{ config, lib, pkgs, ... }:

{
  ##############################################################################
  ## Stylix integration
  ##############################################################################
  stylix.targets.mako.enable = true;

  ##############################################################################
  ## Mako service
  ##############################################################################
  services.mako = {
    enable = true;

    settings = {
      # -------------------------------
      # Appearance
      # -------------------------------
      font          = lib.mkForce "${config.stylix.fonts.monospace.name} 11";
      anchor        = "top-right";     # top-left | top-right | bottom-left | bottom-right
      margin        = "20,40,0,0";     # top,right,bottom,left (px)
      padding       = "10";            # inner padding (px)
      border-size   = 2;               # border thickness (px)
      border-radius = 10;              # rounded corners (px)

      # Colors are provided by Stylix; uncomment to override manually:
      # background-color = "${config.stylix.colors.base00}";
      # text-color       = "${config.stylix.colors.base05}";
      # border-color     = "${config.stylix.colors.base0D}";

      # -------------------------------
      # Behavior
      # -------------------------------
      default-timeout = 3000;          # milliseconds per popup
      ignore-timeout  = false;         # allow natural expiration
      group-by        = "app-name";    # merge notifications from the same app
      max-visible     = 4;             # avoid flooding
      sort            = "-time";       # latest notifications first
      icons           = true;          # show app icons (if provided)
      markup          = true;          # allow Pango markup
      actions         = true;          # enable action buttons when present

      # -------------------------------
      # Display & geometry
      # -------------------------------
      width  = 350;                    # max width in px
      height = 120;                    # max height per notification
      layer  = "overlay";              # draw above most windows

      # Universally follow focused output (do NOT pin to a specific name).
      # If you ever need to pin, set: output = "e.g. eDP-1";
      # But leaving it unset adapts automatically as you plug/unplug displays.
      # output = "eDP-1";

      # -------------------------------
      # Text layout
      # -------------------------------
      text-alignment = "left";         # left | center | right

      # Keep unsupported/experimental options commented to avoid parse errors:
      # transparency = 0.05;
      # progress-bar = false;
    };
  };

  ##############################################################################
  ## Package (optional)
  ## Home Manager installs mako with the service, keeping the package is harmless.
  ##############################################################################
  home.packages = with pkgs; [ mako ];

  ##############################################################################
  ## Do NOT autostart mako from Hyprland
  ## The Home Manager service (and D-Bus activation) handle startup reliably.
  ##############################################################################
  # No exec-once entries here.
}


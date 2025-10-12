# modules/portals.nix
# =============================================================================
# XDG Desktop Portals for Wayland / Hyprland
#
# What this gives me:
# - File pickers, open/save dialogs, and “open with…” that work for sandboxed apps
# - Screen capture & screen sharing (PipeWire-based)
# - A Hyprland-native portal backend so Wayland apps behave correctly
#
# Notes:
# - I explicitly prefer the Hyprland portal, with GTK as a fallback for apps
#   (e.g. Flatpak, GTK apps) that expect the GTK portal.
# - `xdgOpenUsePortal = true` routes `xdg-open` through portals (important on Wayland).
# - I keep the portal packages in systemPackages so CLIs (e.g. debugging) are available,
#   but the actual portal daemons are managed by `xdg.portal.enable = true`.
# - PipeWire (for screenshare/capture) is configured in the multimedia module.
# =============================================================================
{ pkgs, ... }:
{
  ##########################################
  ## Core XDG portal configuration
  ##########################################
  xdg.portal = {
    enable = true;

    # Route xdg-open through the portal on Wayland (fixes many desktop-opener quirks)
    xdgOpenUsePortal = true;

    # Prefer the Hyprland backend; keep GTK as a sensible fallback.
    # Order matters: the first in `config.common.default` is preferred.
    config.common.default = [ "hyprland" "gtk" ];

    # Make sure these two backends are available to the portal service.
    extraPortals = [
      pkgs.xdg-desktop-portal-hyprland
      pkgs.xdg-desktop-portal-gtk
    ];
  };

  ##########################################
  ## Packages (handy CLIs & backends)
  ##########################################
  environment.systemPackages = with pkgs; [
    # Portal launcher/daemon (service runs from xdg.portal.enable)
    xdg-desktop-portal

    # Hyprland-native portal (Wayland screen share, pickers, etc.)
    xdg-desktop-portal-hyprland

    # GTK fallback portal (many Flatpaks/GTK apps expect this)
    xdg-desktop-portal-gtk

    # xdg-open, xdg-mime, etc. (useful utilities)
    xdg-utils
  ];

  ##########################################
  ## Polkit (GUI auth prompts for privileged ops)
  ##########################################
  # Required for permission dialogs (mounting drives, network changes, etc.)
  security.polkit.enable = true;

  ##########################################
  ## Optional: Flatpak integration
  ##########################################
  # Flatpak apps rely heavily on portals for file pickers and screen share.
  # Enable this if I use Flatpak; otherwise leave it off.
  # services.flatpak.enable = true;

  ##########################################
  ## Optional: Electron/Chromium screen sharing tips
  ##########################################
  # Most apps Just Work™ with hyprland portal + PipeWire. If some Electron apps
  # mis-detect the DE, ensuring XDG_CURRENT_DESKTOP is set to "Hyprland" can help.
  # Hyprland usually exports this itself; if I need to force it:
  # environment.sessionVariables.XDG_CURRENT_DESKTOP = "Hyprland";

  ##########################################
  ## Optional: KDE/Qt apps (if I use them a lot)
  ##########################################
  # If I prefer KDE’s portal behavior for Qt apps, I can add:
  #   xdg.portal.extraPortals = xdg.portal.extraPortals ++ [ pkgs.xdg-desktop-portal-kde ];
  # and move "kde" earlier in config.common.default, e.g.:
  #   xdg.portal.config.common.default = [ "hyprland" "kde" "gtk" ];
}


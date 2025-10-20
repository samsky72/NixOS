# modules/portals.nix
# =============================================================================
# XDG Desktop Portals for Wayland / Hyprland
#
# Provides
#   • File pickers, open/save dialogs, and “open with…” for sandboxed apps
#   • Screen capture & screen sharing via PipeWire
#   • Hyprland-native portal backend; GTK fallback for broader app support
#
# Notes
#   • `gtkUsePortal` was removed upstream; do not set it.
#   • Order in `config.common.default` matters: earlier backends are preferred.
#   • `xdgOpenUsePortal = true` routes xdg-open through portals on Wayland.
#   • PipeWire configuration is handled in the multimedia module.
# =============================================================================
{ pkgs, ... }:
{
  ##########################################
  ## Core XDG portal configuration
  ##########################################
  xdg.portal = {
    enable = true;

    # Route xdg-open through the portal (reliable on Wayland).
    xdgOpenUsePortal = true;

    # Prefer the Hyprland backend; keep GTK as a fallback.
    # The first entry is the preferred one.
    config.common.default = [ "hyprland" "gtk" ];

    # Ensure these backends are available to the portal service.
    extraPortals = [
      pkgs.xdg-desktop-portal-hyprland
      pkgs.xdg-desktop-portal-gtk
    ];
  };

  ##########################################
  ## Useful userland helpers
  ##########################################
  environment.systemPackages = with pkgs; [
    xdg-utils                 # xdg-open, xdg-mime, etc.
  ];

  ##########################################
  ## Polkit (GUI auth prompts for privileged ops)
  ##########################################
  security.polkit.enable = true;

  ##########################################
  ## Optional: Flatpak integration
  ##########################################
  # services.flatpak.enable = true;

  ##########################################
  ## Optional: Electron/Chromium screen sharing tips
  ##########################################
  # Some Electron apps may mis-detect the desktop environment.
  # Hyprland typically exports XDG_CURRENT_DESKTOP; to force it:
  # environment.sessionVariables.XDG_CURRENT_DESKTOP = "Hyprland";

  ##########################################
  ## Optional: KDE/Qt portal behavior
  ##########################################
  # For KDE-heavy setups, add the KDE portal and prefer it for Qt apps:
  # xdg.portal.extraPortals = xdg.portal.extraPortals ++ [ pkgs.xdg-desktop-portal-kde ];
  # xdg.portal.config.common.default = [ "hyprland" "kde" "gtk" ];
}


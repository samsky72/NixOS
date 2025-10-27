# modules/hyprland.nix
# =============================================================================
# Wayland desktop with Hyprland and a GUI greeter (GDM).
#
# Scope
#   • Enables Hyprland as the compositor
#   • Provides a graphical login via GDM
#   • Keeps XWayland available for legacy X11 applications
#   • Configures portals for screensharing and file dialogs
#
# Characteristics
#   • Host-agnostic; no display layout or user-specific logic
#   • Hyprland session appears in GDM’s session list
# =============================================================================
{ pkgs, lib, ... }:

{
  ##########################################
  ## Hyprland (Wayland compositor)
  ##########################################
  programs.hyprland = {
    enable = true;          # Hyprland compositor
    xwayland.enable = true; # X11 app compatibility under Wayland
  };

  ##########################################
  ## Display server + GUI greeter (GDM)
  ##########################################
  # The X server module manages display managers on NixOS.
  services.xserver.enable = true;

  services.displayManager.gdm = {
    enable = true;          # Graphical greeter (Wayland by default)
    # wayland = true;       # Wayland is default; uncomment to force
  };

  ##########################################
  ## Desktop portals (screenshare, file dialogs, etc.)
  ##########################################
  xdg.portal = {
    enable = true;
    # GTK portal complements the Hyprland portal for common apps.
    extraPortals = [
      pkgs.xdg-desktop-portal-gtk
      pkgs.xdg-desktop-portal-hyprland
    ];
  };

  ##########################################
  ## Wayland-oriented environment variables
  ##########################################
  environment.sessionVariables = {
    XDG_SESSION_TYPE = "wayland";   # Prefer Wayland
    MOZ_ENABLE_WAYLAND = "1";       # Firefox Wayland backend
    QT_QPA_PLATFORM   = "wayland";  # Qt Wayland backend
    NIXOS_OZONE_WL    = "1";        # Chromium/Electron Wayland backend
    WLR_NO_HARDWARE_CURSORS = "1";  # Cursor rendering workaround on some GPUs
  };

  ##########################################
  ## Utilities (optional)
  ##########################################
  environment.systemPackages = with pkgs; [
    # Tools useful on Hyprland-based desktops
    xdg-desktop-portal-gtk
    xdg-desktop-portal-hyprland
  ];
}


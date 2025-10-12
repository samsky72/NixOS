# modules/hyprland.nix
{ pkgs, defaultUser, ... }: {
 
  ##########################################
  ## Wayland + Hyprland Desktop Environment
  ##########################################
  ## This module configures Hyprland as the primary compositor,
  ## disables legacy X11, and provides a greetd-based login flow
  ## with tuigreet for a minimal and clean TUI login experience.
  ##########################################

  # Enable the Hyprland compositor (Wayland-native window manager)
  programs.hyprland ={
    enable = true;
    xwayland.enable = true;
  };

  services.xserver.enable = true;
  programs.xwayland.enable = true;

  ##########################################
  ## Login Manager — greetd + tuigreet
  ##########################################
  # greetd is a simple display/login manager that runs a chosen
  # TUI or GUI greeter; tuigreet provides a minimal terminal-based UI.
  services.displayManager.gdm = {
    enable = true;
  };

  ##########################################
  ## Wayland-related Environment Variables
  ##########################################
  environment.sessionVariables = {
    # Enable native Wayland support for Firefox
    MOZ_ENABLE_WAYLAND = "1";

    # Explicitly mark session type as Wayland (used by many apps)
    XDG_SESSION_TYPE = "wayland";

    # Workaround for certain GPUs with cursor rendering issues
    # (mainly Intel or hybrid graphics)
    WLR_NO_HARDWARE_CURSORS = "1";
  };
}


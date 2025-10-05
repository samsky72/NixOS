# modules/portals.nix
{ pkgs, ... }: {

  ##########################################
  ## XDG Desktop Portals for Wayland / Hyprland
  ##
  ## These provide system-level integrations like:
  ## - File pickers
  ## - Screenshots & screen sharing
  ## - Open/save dialogs for sandboxed apps
  ##
  ## The Hyprland portal ensures native support on Wayland.
  ##########################################

  xdg.portal = {
    enable = true;

    # Hyprland portal backend (Wayland-native)
    extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];

    # Fallback ordering for other apps (GTK/Flatpak)
    config.common.default = [ "hyprland" "gtk" ];
  };

  ##########################################
  ## Related Quality-of-Life Packages
  ##########################################
  environment.systemPackages = with pkgs; [
    xdg-desktop-portal
    xdg-desktop-portal-hyprland
    xdg-desktop-portal-gtk     # fallback for GTK/Flatpak apps
    xdg-utils                   # ensures `xdg-open` etc. work properly
  ];

  ##########################################
  ## Polkit — required for permissions dialogs
  ##
  ## Enables GUI prompts for privileged actions,
  ## such as mounting drives, network changes, etc.
  ##########################################
  security.polkit.enable = true;
}


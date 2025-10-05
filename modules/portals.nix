# modules/portals.nix
{ pkgs, lib, ... }:
{
  ##########################################
  ## XDG Desktop Portals for Wayland/Hyprland
  ##########################################

  xdg.portal = {
    enable = true;

    # Add Hyprland-specific backend
    extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];

    # Optionally set default backend priorities (useful if running multiple compositors)
    config = {
      common = {
        default = [ "hyprland" "gtk" ];
      };
    };
  };

  ##########################################
  ## Related quality-of-life packages
  ##########################################
  environment.systemPackages = with pkgs; [
    xdg-desktop-portal
    xdg-desktop-portal-hyprland
    xdg-desktop-portal-gtk   # fallback for GTK apps
  ];

  # Polkit for permission dialogs (some portals require it)
  security.polkit.enable = true;
}

# home/modules/udiskie.nix
# =============================================================================
# User-session automounter with notifications and (optional) tray icon.
# Pairs with system-side: services.udisks2.enable = true; services.gvfs.enable = true;
# I run this in my session; mounts show up under /run/media/$USER/…
# =============================================================================
{ config, lib, pkgs, ... }:
{
  ##########################################
  ## udiskie (Home Manager user service)
  ##########################################
  services.udiskie = {
    enable = true;        # start udiskie as a user service
    automount = true;     # auto-mount removable drives
    notify = true;        # desktop notifications on mount/unmount
    tray = "auto";        # show tray icon if a tray is available (Waybar/SNI)
    # settings = { };     # place extra udiskie.toml options here if I need them
  };

  ##########################################
  ## Optional user-side helpers
  ##########################################
  home.packages = with pkgs; [
    udiskie          # CLI client handy for manual control/logging
  ];
}


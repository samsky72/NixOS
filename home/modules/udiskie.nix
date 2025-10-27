# home/modules/udiskie.nix
# =============================================================================
# Udiskie — user-session automounter with notifications and optional tray icon.
#
# Provides
#   • Per-user udiskie service (no system-wide daemon needed beyond UDisks2)
#   • Automount of removable media under /run/media/$USER/<LABEL or UUID>
#   • Desktop notifications on mount/unmount
#   • Tray icon when a StatusNotifier/legacy tray is present (e.g. Waybar)
#
# System requirements (handled in system modules, not here)
#   services.udisks2.enable = true     # device and volume management backend
#   services.gvfs.enable    = true     # trash, MTP, SMB, and other VFS backends
#   security.polkit.enable  = true     # privilege prompts for mount/format operations
#
# Notes
#   • Avoid overlapping automounters (e.g. Thunar-volman “auto-mount on insert”).
#     Udiskie should be the single authority for automounting in the session.
#   • Notifications rely on a running notification daemon (e.g. mako).
#   • The tray = "auto" value enables an indicator only when a tray is available.
#   • Extra tuning (per-FS mount options, device ignore rules, file manager open-on-mount)
#     can be provided via `services.udiskie.settings`; left empty here to keep defaults.
# =============================================================================
{ config, lib, pkgs, ... }:
{
  ##########################################
  ## Udiskie user service
  ##########################################
  services.udiskie = {
    enable    = true;   # start udiskie in the user session
    automount = true;   # mount newly seen removable devices automatically
    notify    = true;   # show desktop notifications for mount/unmount
    tray      = "auto"; # show tray icon if a tray is present (Waybar/SNI), else headless

    # Optional configuration (kept empty for safe defaults).
    # Populate with TOML keys as a Nix attrset; udiskie will receive a TOML file.
    # Example (uncomment and adjust):
    #
    # settings = {
    #   # Launch a file manager on new mount (explicit path avoids $PATH ambiguity)
    #   program_options = {
    #     file_manager = "${pkgs.xfce.thunar}/bin/thunar";
    #     terminal     = "${pkgs.kitty}/bin/kitty";
    #   };
    #
    #   # Example per-filesystem mount options (kernel ntfs3/exfat/vfat shown):
    #   #
    #   # udiskie expects a mapping like:
    #   #   mount_options = { "<fstype>" = [ "opt1", "opt2", ... ]; }
    #   # Validate against `udiskie --help` and upstream docs for your version.
    #   mount_options = {
    #     ntfs  = [ "uid=%U" "gid=%G" "umask=0077" "windows_names" ];
    #     exfat = [ "uid=%U" "gid=%G" "umask=0077" ];
    #     vfat  = [ "uid=%U" "gid=%G" "umask=0077" "shortname=mixed" "utf8=1" ];
    #   };
    #
    #   # Example device ignore rules (skip internal/system disks)
    #   # device_config = [
    #   #   { match = { is_system = true;   }; ignore = true; }
    #   #   { match = { id_type   = "loop"; }; ignore = true; }
    #   # ];
    # };
  };

  ##########################################
  ## Optional CLI (useful for inspection)
  ##########################################
  home.packages = with pkgs; [
    udiskie  # `udiskie --help`, `udiskie --no-automount --verbose` for debugging
  ];

  ##########################################
  ## Operational tips
  ##########################################
  # • Logs (live):       journalctl --user -u udiskie -f
  # • Dry run (no automount):  udiskie --no-automount --verbose
  # • Show known devices:      udiskie -l
  # • Mount path convention:   /run/media/$USER/<LABEL or UUID>
  #
  # If mounts do not appear:
  #   1) Confirm UDisks2 is running (system):  systemctl status udisks2
  #   2) Confirm Polkit is enabled for prompts: security.polkit.enable = true
  #   3) Ensure no second automounter is acting (e.g. Thunar-volman auto-mount)
  #   4) Check notifications daemon (e.g. `mako`) if toasts are expected
}


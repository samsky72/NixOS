# home/modules/kdeconnect.nix
# =============================================================================
# KDE Connect (Home Manager)
#
# Purpose
#   • Enables KDE Connect as a per-user service (spawns `kdeconnectd`)
#   • Optionally starts the tray indicator (`kdeconnect-indicator`)
#
# Notes
#   • Firewall: system config should allow TCP/UDP 1714–1764 for discovery/links.
#     (Handled in the system-level networking module, not here.)
#   • Tray: the indicator appears only if a Status Notifier host exists
#     (e.g., Waybar with a tray, KDE Plasma, etc.).
# =============================================================================
{ pkgs, ... }:
{
  services.kdeconnect = {
    enable = true;     # start kdeconnectd for this user session
    indicator = true;  # auto-launch the tray indicator when a tray is available
  };
}


# home/modules/kdeconnect.nix
# -----------------------------------------------------------------------------
# I enable KDE Connect as a user service. This starts `kdeconnectd` in my session
# and installs the tools: `kdeconnect-cli`, `kdeconnect-settings`, etc.
# If I want a tray icon, I can launch `kdeconnect-indicator` (see notes below).
# -----------------------------------------------------------------------------
{ pkgs, ... }:

{
  services.kdeconnect = {
    enable = true;
    indicator = true;
  };
}
 


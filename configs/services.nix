# SystemD and services configurations.
{ config, ... }: { 
  systemd = { 
    extraConfig = '' DefaultTimeoutStopSec=10s '';          # Set services stop timeout to 10 sec.
  };
  services = {
    blueman.enable = true;                                  # Use Blueman for bluetooth.
    gvfs.enable = true;                                     # Enable auto mounting of removable drives.
    upower.enable = true;                                   # Automatic power configurations.
 };
}

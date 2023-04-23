# Bluetooth configurations.
{ config, pkgs, ... }: { 
  hardware.bluetooth = {
    enable = true;                        # Enable Bluetooth support.
    hsphfpd.enable = true;                # Enable HSP/HFP profiles.
    package = pkgs.bluezFull;             # Use full bluez package.
  };
}

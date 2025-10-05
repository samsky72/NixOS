# modules/services.nix
{ lib, pkgs, ... }:
{
  ##########################################
  ## Basic services
  ##########################################

  # Disable printing (CUPS)
  services.printing.enable = false;

  # Enable SSH for remote access
  services.openssh = {
    enable = true;

    # Harden defaults
    settings = {
      PermitRootLogin = "no";          # block direct root login
      PasswordAuthentication = false;  # require SSH key
    };
  };

  ##########################################
  ## Optional: more system-level services
  ##########################################
  # Example: Bluetooth
  # hardware.bluetooth.enable = true;

  # Example: power management
  # services.upower.enable = true;
}


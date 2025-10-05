# modules/services.nix
{ pkgs, ... }:
{
  ##########################################
  ## System Services Configuration
  ##
  ## Provides essential background daemons
  ## such as SSH, power management, and logging.
  ##########################################

  ##########################################
  ## SSH Server (secure remote access)
  ##########################################
  services.openssh = {
    enable = true;

    # Harden SSH settings
    settings = {
      PermitRootLogin = "no";          # Prevent direct root login
      PasswordAuthentication = false;  # Enforce SSH key authentication
      X11Forwarding = false;           # Disable unnecessary forwarding
      AllowTcpForwarding = "no";       # Reduce attack surface
      ClientAliveInterval = 120;       # Keep connections alive
      ClientAliveCountMax = 2;
    };
  };

  ##########################################
  ## System Logging & Monitoring
  ##########################################
  services.journald = {
    rateLimitInterval = "30s";
    rateLimitBurst = 1000;
    storage = "auto";
  };

  ##########################################
  ## Power Management (Laptop-friendly)
  ##########################################
  services.upower.enable = true;        # Track battery, suspend, etc.
  services.power-profiles-daemon.enable = true; # Manage CPU power modes

  ##########################################
  ## Optional: Time Synchronization
  ##########################################
  services.timesyncd.enable = true; # Keeps system clock accurate

  ##########################################
  ## Optional: GNOME keyring (for SSH, secrets, etc.)
  ##########################################
  services.gnome.gnome-keyring.enable = true;
}



# modules/services.nix
# =============================================================================
# System services (shared, sensible defaults)
#
# Provides
#   • OpenSSH with key-only auth and conservative server limits
#   • Journald with rate-limiting and optional retention caps
#   • Laptop-friendly power management (power-profiles-daemon + upower)
#   • Time sync via systemd-timesyncd (lightweight NTP)
#   • GNOME Keyring for desktop secrets and SSH agent integration
#
# Notes
#   • Firewall exposure is separate; open TCP/22 (or the chosen port) there.
#   • Prefer either power-profiles-daemon or TLP (this picks PPD).
#   • Journald defaults are typically sufficient; caps are included as comments.
# =============================================================================
{ pkgs, lib, ... }:
{
  ##########################################
  ## SSH server (hardened, key-only)
  ##########################################
  services.openssh = {
    enable = true;

    # Open the port in a firewall module elsewhere, e.g.:
    # networking.firewall.allowedTCPPorts = [ 22 ];

    # sshd_config(5) options (CamelCase → native sshd keys).
    settings = {
      # --- Access policy -------------------------------------------------------
      PermitRootLogin            = "no";     # block direct root login
      PasswordAuthentication     = false;    # enforce public-key auth
      KbdInteractiveAuthentication = false;  # disable keyboard-interactive
      PubkeyAuthentication       = true;     # explicit for clarity
      PermitEmptyPasswords       = false;    # reject empty passwords
      MaxAuthTries               = 3;        # reduce brute-force surface
      LoginGraceTime             = "30s";    # close unauthenticated sessions quickly

      # --- Forwarding / exposure ----------------------------------------------
      X11Forwarding              = false;    # disable X11 forwarding
      AllowTcpForwarding         = "no";     # disable local/remote port forwarding
      AllowAgentForwarding       = "no";     # disable agent forwarding
      GatewayPorts               = "no";     # do not bind remote forwards to 0.0.0.0

      # --- Keep-alive / idle control ------------------------------------------
      ClientAliveInterval        = 120;      # ping every 2 minutes
      ClientAliveCountMax        = 2;        # drop after ~4 minutes of silence

      # --- Optional hardening knobs (uncomment to use) -------------------------
      # Port = 22;                          # move to a non-default port to cut noise
      # AllowUsers  = "samsky";             # restrict to explicit users
      # AllowGroups = "sshusers";           # or to a group
      # UseDNS      = "no";                 # avoid reverse DNS lookups on connect
      # Compression = "no";                 # reduce CPU use; leave "yes" on slow links
      #
      # Ciphers / MACs / KEX examples (match client fleet before enabling):
      # Ciphers = "chacha20-poly1305@openssh.com,aes256-gcm@openssh.com";
      # MACs    = "hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com";
      # KexAlgorithms = "sntrup761x25519-sha512@openssh.com";
    };

    # Optional: pin host key types/paths explicitly.
    # hostKeys = [
    #   { path = "/etc/ssh/ssh_host_ed25519_key"; type = "ed25519"; }
    #   { path = "/etc/ssh/ssh_host_rsa_key";     type = "rsa";     }
    # ];
  };

  ##########################################
  ## System logging (journald)
  ##########################################
  services.journald = {
    storage          = "auto";  # persistent if /var/log/journal exists, else volatile
    rateLimitInterval = "30s";  # throttle bursts
    rateLimitBurst    = 1000;

    # Optional retention caps (uncomment to bound usage/age):
    # SystemMaxUse     = "1G";     # cap journal size on disk
    # SystemKeepFree   = "500M";   # leave free space on the FS
    # MaxFileSec       = "14day";  # rotate out older files
    # MaxRetentionSec  = "30day";  # drop entries older than this
  };

  ##########################################
  ## Power management (laptop-friendly)
  ##########################################
  services.power-profiles-daemon.enable = true;  # Balanced/Performance/Power Saver
  services.upower.enable = true;                 # battery/energy stats for DE applets

  # Optional: logind policies for lid/idle (tune per host/DE).
  # services.logind = {
  #   lidSwitch               = "suspend";  # e.g., "ignore" for docked desktops
  #   lidSwitchExternalPower  = "suspend";
  #   idleAction              = "suspend";
  #   idleActionSec           = "30min";
  # };

  ##########################################
  ## Time synchronization (NTP)
  ##########################################
  services.timesyncd = {
    enable = true;
    # Optional deterministic sources:
    # servers     = [ "0.pool.ntp.org" "1.pool.ntp.org" ];
    # fallbackNTP = [ "time.cloudflare.com" "time.google.com" ];
  };

  ##########################################
  ## GNOME Keyring (desktop secrets / SSH agent)
  ##########################################
  services.gnome.gnome-keyring.enable = true;
  # Note: Polkit is typically enabled elsewhere (e.g., portals module) for GUI auth prompts.

  ##########################################
  ## Optional extras (hygiene / hardening)
  ##########################################
  # 1) Fail2ban — useful if SSH is exposed to the internet
  # services.fail2ban = {
  #   enable   = true;
  #   bantime  = "1h";
  #   findtime = "10m";
  #   maxretry = 5;
  #   jails.sshd = ''
  #     enabled = true
  #     port    = ssh
  #     filter  = sshd
  #     logpath = %(sshd_log)s
  #     backend = systemd
  #   '';
  # };

  # 2) Avahi/mDNS — convenient on trusted LANs, avoid on untrusted networks
  # services.avahi = {
  #   enable      = true;
  #   nssmdns     = true;   # resolve *.local hostnames
  #   openFirewall = true;
  # };

  # 3) Sysstat — iostat/mpstat for performance diagnostics
  # services.sysstat.enable = true;
}


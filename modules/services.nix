# modules/services.nix
# =============================================================================
# System Services (shared & sensible defaults)
#
# Goals:
# - Secure, key-only SSH with tight server-side limits.
# - Predictable logging (journald) with optional retention caps.
# - Laptop-friendly power management via power-profiles-daemon + upower.
# - Accurate time via systemd-timesyncd (lightweight NTP).
# - GNOME Keyring for desktop secrets & SSH agent integration.
#
# Notes:
# - SSH port exposure still depends on your firewall. If you run a firewall,
#   remember to allow TCP/22 explicitly (or change the port here and allow that).
# - power-profiles-daemon and TLP overlap; use only one (this module picks PPD).
# - journald defaults are fine; caps are provided as commented options below.
# =============================================================================
{ pkgs, lib, ... }:
{
  ##########################################
  ## SSH Server (secure remote access)
  ##########################################
  services.openssh = {
    enable = true;

    # If you run a firewall module elsewhere, ensure port 22 is allowed there:
    # networking.firewall.allowedTCPPorts = [ 22 ];

    # Harden the daemon with modern, key-only authentication and conservative limits.
    # Values map to upstream sshd_config(5) keys.
    settings = {
      # --- Access policy ---
      PermitRootLogin          = "no";     # never allow direct root login
      PasswordAuthentication   = false;    # enforce key-based auth only
      KbdInteractiveAuthentication = false;# disable keyboard-interactive
      PubkeyAuthentication     = true;     # explicit for clarity
      PermitEmptyPasswords     = false;    # disallow empty passwords
      MaxAuthTries             = 3;        # mitigate brute force
      LoginGraceTime           = "30s";    # close unauthenticated sessions fast

      # --- Forwarding / exposure ---
      X11Forwarding            = false;    # disable X11 forwarding
      AllowTcpForwarding       = "no";     # turn off local/remote TCP forwarding
      AllowAgentForwarding     = "no";     # disallow agent forwarding
      GatewayPorts             = "no";     # do not bind remote forwards to wildcard

      # --- Keepalives / idle control ---
      ClientAliveInterval      = 120;      # probe clients every 2 minutes
      ClientAliveCountMax      = 2;        # drop after ~4 minutes of silence

      # --- (Optional) Listen on a non-standard port to cut noise —
      # Port = 22;

      # --- (Optional) Restrict by users/groups —
      # AllowUsers  = "samsky";
      # AllowGroups = "sshusers";
    };

    # (Optional) host key policy:
    # hostKeys = [
    #   { path = "/etc/ssh/ssh_host_ed25519_key"; type = "ed25519"; }
    #   { path = "/etc/ssh/ssh_host_rsa_key";     type = "rsa";     }
    # ];
  };

  ##########################################
  ## System Logging (journald)
  ##########################################
  services.journald = {
    # Default storage behavior: use /var/log/journal (persistent) if it exists;
    # otherwise keep logs in /run/log/journal (volatile).
    storage = "auto";

    # Rate-limit bursts to avoid log storms.
    rateLimitInterval = "30s";
    rateLimitBurst    = 1000;

    # (Optional) Retention caps — uncomment to bound disk usage/age.
    # SystemMaxUse     = "1G";     # hard cap for /var/log/journal usage
    # SystemKeepFree   = "500M";   # leave this many bytes free on FS
    # MaxFileSec       = "14day";  # rotate out files older than this
    # MaxRetentionSec  = "30day";  # drop any entries older than this
  };

  ##########################################
  ## Power Management (Laptop-friendly)
  ##########################################
  # Runtime power tuning and profile switching (balanced/performance/power-saver).
  services.power-profiles-daemon.enable = true;

  # UPower surfaces battery stats and integrates with many desktops/DE applets.
  services.upower.enable = true;

  # (Optional) Logind policies for lid events / idle actions (tune per host/DE).
  # services.logind = {
  #   lidSwitch = "suspend";             # or "ignore" on docked desktop setups
  #   lidSwitchExternalPower = "suspend";
  #   idleAction = "suspend";            # or "ignore"
  #   idleActionSec = "30min";
  # };

  ##########################################
  ## Time Synchronization (NTP)
  ##########################################
  # Lightweight, reliable time sync via systemd-timesyncd.
  services.timesyncd = {
    enable = true;

    # (Optional) Custom NTP pool if you want deterministic sources:
    # servers     = [ "0.pool.ntp.org" "1.pool.ntp.org" ];
    # fallbackNTP = [ "time.cloudflare.com" "time.google.com" ];
  };

  ##########################################
  ## GNOME Keyring (desktop secrets & SSH)
  ##########################################
  # Provides a session keyring and can act as an SSH agent; many desktop apps expect it.
  services.gnome.gnome-keyring.enable = true;

  ##########################################
  ## (Optional) Extra hardening / quality-of-life
  ##########################################
  # 1) Fail2ban (ban IPs with repeated auth failures; useful if SSH exposed)
  # services.fail2ban = {
  #   enable = true;
  #   bantime = "1h";
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

  # 2) Avahi/mDNS (handy for discovery on LAN; leave disabled on untrusted nets)
  # services.avahi = {
  #   enable = true;
  #   nssmdns = true;     # resolve *.local hostnames
  #   openFirewall = true;
  # };

  # 3) Sysstat (iostat/mpstat for performance diagnostics)
  # services.sysstat.enable = true;
}


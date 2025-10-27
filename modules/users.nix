# modules/users.nix
# =============================================================================
# Users (primary account + shell)
#
# Provides
#   • System-wide Zsh availability
#   • Primary user (from `defaultUser`) with Zsh as login shell
#   • Secure, repo-safe authentication options (SSH keys / hashed file)
#
# Notes
#   • Plaintext passwords should not be committed; prefer SSH keys or a hashed file.
#   • Extra groups are conservative defaults for a desktop; trim as needed.
# =============================================================================
{ pkgs, lib, defaultUser, ... }:
{
  ##########################################
  ## Shell availability (system-wide)
  ##########################################
  programs.zsh.enable = true;

  ##########################################
  ## Primary group (same name as user, fixed GID)
  ##########################################
  # GID is intentionally set to 1000 for consistency across hosts.
  users.groups.${defaultUser} = { gid = 1000; };

  ##########################################
  ## Main user account
  ##########################################
  users.users.${defaultUser} = {
    isNormalUser = true;
    description  = "Primary user";
    home         = "/home/${defaultUser}";
    group        = defaultUser;        # primary group
    shell        = pkgs.zsh;           # default login shell

    # Desktop/admin groups:
    # - wheel: sudo
    # - networkmanager: manage networking
    # - audio/video: multimedia access (PipeWire/VAAPI, etc.)
    # - input,uinput: some input tools (gaming, key remappers) may require these
    # - lp,scanner: printing/scanning access (if CUPS/SANE enabled)
    # - adbusers: Android adb access (if programs.adb.enable = true)
    extraGroups = [
      "wheel"
      "networkmanager"
      "audio"
      "video"
      "input"
      # "uinput"     # uncomment if userland input needs it and hardware.uinput.enable = true
      # "lp" "scanner"   # printing/scanning modules provide these
      # "adbusers"       # enable alongside programs.adb.enable = true
    ];

    ########################################
    ## Authentication — pick ONE approach
    ########################################

    # 1) SSH keys only (recommended)
    openssh.authorizedKeys.keys = [
      # "ssh-ed25519 AAAA... user@host"
    ];
    # openssh.authorizedKeys.keyFiles = [
    #   "/etc/ssh/authorized_keys.d/${defaultUser}"
    # ];

    # 2) Hashed password from a file (repo-safe). Generate with: mkpasswd -m sha-512
    # hashedPasswordFile = "/run/secrets/users/${defaultUser}.pw";

    # 3) Temporary password (for initial local bring-up only; do not commit long-term)
    # initialPassword = "Password100";

    # Optional hardening (locks the user DB to declarative state)
    # users.mutableUsers = false;
  };

  ##########################################
  ## Optional: passwordless sudo for wheel
  ##########################################
  # security.sudo.wheelNeedsPassword = false;  # keep requiring a password by default
}


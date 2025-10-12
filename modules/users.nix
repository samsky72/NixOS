# modules/users.nix
# -----------------------------------------------------------------------------
# Minimal user module:
# - Ensures Zsh is available system-wide
# - Creates the primary user (from `defaultUser`)
# - Sets Zsh as the default shell for that user
# - Leaves auth flexible (SSH keys or a TEMPORARY password)
# -----------------------------------------------------------------------------
{ pkgs, defaultUser, ... }: {

  ##########################################
  ## Shell availability (system-wide)
  ##########################################
  # Make sure Zsh is installed and registered as a valid login shell.
  programs.zsh.enable = true;

  ##########################################
  ## Primary group for the main user
  ##########################################
  # Creates a group with the same name as the user.
  # NOTE: Hard-coding a GID (1000) is optional; remove if you prefer auto-allocation.
  users.groups.${defaultUser} = { gid = 1000; };

  ##########################################
  ## Main user account
  ##########################################
  users.users.${defaultUser} = {
    isNormalUser = true;

    # Associate with the primary group defined above
    group = defaultUser;

    # Useful desktop/admin groups:
    # - wheel: sudo
    # - networkmanager: manage networking
    # - audio/video: multimedia permissions
    extraGroups = [ "audio" "video" "wheel" "networkmanager" ];

    # ✅ Default login shell is Zsh
    shell = pkgs.zsh;

    ##########################################
    ## Authentication (pick ONE approach)
    ##########################################
    # 1) TEMPORARY password — DO NOT COMMIT long-term.
    #    Change immediately after first login with `passwd`.
    initialPassword = "Password100";

    # 2) SSH keys only (recommended). Uncomment and add your public key(s):
    # openssh.authorizedKeys.keys = [
    #   "ssh-ed25519 AAAA... your-public-key"
    # ];

    # 3) Hashed password file (safer for git). Example:
    # hashedPasswordFile = "/etc/secrets/${defaultUser}.pw";
    # And consider:
    # users.mutableUsers = false;  # lock user DB to declarative state
  };
}


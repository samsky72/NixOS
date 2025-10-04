# modules/users.nix
{ pkgs, lib, defaultUser, ... }:
{
  # Create group explicitly (group name same as user)
  users.groups.${defaultUser} = { };

  users.users.samsky = {
    isNormalUser = true;
    description = ${defaultUser};
    extraGroups = [ "wheel" "networkmanager" "samsky" ];
    shell = pkgs.bashInteractive;

    # For a fresh install, pick ONE method of authentication:
    # 1) Temporary password (change immediately after first boot):
    initialPassword = "Password100";

    # 2) Or, safer: authorized SSH keys
    # openssh.authorizedKeys.keys = [
    #   "ssh-ed25519 AAAA... yourkey"
    # ];
  };
}

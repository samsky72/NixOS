# modules/users.nix
{ pkgs, defaultUser, ... }: {

  ##########################################
  ## User and group configuration
  ##########################################

  # Create primary group (same name as user)
  users.groups.${defaultUser} = { gid = 1000; };
  
  # Define the main user account
  users.users.${defaultUser} = {
    isNormalUser = true;
    group = defaultUser;  # assign to primary group
    extraGroups = [ "audio" "video" "wheel" "networkmanager" ];  # admin & network privileges
    shell = pkgs.bashInteractive;

    ##########################################
    ## Authentication
    ##########################################
    # Choose only one:
    initialPassword = "Password100";  # temporary, change immediately
    # openssh.authorizedKeys.keys = [
    #   "ssh-ed25519 AAAA...yourkey"
    # ];
  };
}


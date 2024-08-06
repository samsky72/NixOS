# Users configurations.
{ config, userName, ... }: {
  
  # Define user configuration.
  users = {  

    # Define user group.
    groups.${userName} = { gid = 1000; };

    # Define user.
    users.${userName} = {
      createHome = true;                                                                # Create home folder by default.
      group = userName;                                                                 # Define default group.
      initialPassword = "Password100";                                                  # Define initial password.
      isNormalUser = true;                                                              # It is normal user.
      extraGroups = ["adbuser" "audio" "networkmanager" "video" "wheel" "wireshark"];   # Add extra groups.
    };   
  }; 
}

# User accounts configurations.
{ config, pkgs, ... }: { 
  users = {
    groups.samsky = { gid = 1001; };              # Create group samsky with group id 1001. 
    users = { 
      samsky = {
        createHome = true;                        # Create home directory by default.
        group = "samsky";                         # Assign samsky group as primary group.
        extraGroups = [ 
          "adbusers"                              # Allow adb usage.
          "audio"                                 # Allow access to audio.
          "networkmanager"                        # Allow cofigure Network Manager.
          "vboxusers"                             # Allow Virtual Box usage.
          "video"                                 # Allow access to video.
          "wheel"                                 # Allow su and sudo usage. 
          "wireshark"                             # Allow Wireshark usage.
        ];                                                         
        initialPassword = "Password100";          # Initial default password.
        isNormalUser = true;                      
        shell = pkgs.zsh;                         # Use zsh as default shell.
      };
    };
  };
}

# Boot configurations.
{ config, pkgs, ... }: {

  # Define boot configuration. 
  boot = {

    # Use Zen kernel.
    kernelPackages = pkgs.linuxPackages_zen;
    
    # Boot loader configuration.
    loader = {
      systemd-boot.enable = true;               # Use systemd boot loader.
      efi.canTouchEfiVariables = true; 
    };
    
    # Define supported file systems. 
    supportedFilesystems = {
      ext4 = true;                              # Use Ext4.
      ntfs = true;                              # Use NTFS.
      vfat = true;                              # Use VFAT.
    };

    # Define /tmp configuration.
    tmp = { 
      cleanOnBoot = true;                       # Clean it on boot.
      useTmpfs = true;                          # Use tmpfs for /tmp.
    };
  };
}

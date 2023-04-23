# Boot options.
{ config, pkgs, ... } : {
  boot = {
    kernelPackages = pkgs.linuxPackages_zen;            # Use zen kernel.
    loader = {
      systemd-boot.enable = true;                       # Use the systemd-boot EFI boot loader.
      efi.canTouchEfiVariables = true;
    };
    supportedFilesystems = [ "ext4" "ntfs" "vfat" ];    # Define supported file systems.
    tmp = {
      cleanOnBoot = true;                               # Clean tmp directory on boot.
      useTmpfs = true;                                  # Enable mapping of tmp on tmpfs.
    };
  };
} 

# Zephyrus Duo 16 configurations..
{ config, lib, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  # Boot modules configurations.
  boot = {
    extraModulePackages = [];
    initrd = {
      availableKernelModules = [ "nvme" "xhci_pci" "usbhid" "usb_storage" "sd_mod" ];
      kernelModules = [ ];
    };
    kernelModules = [ "kvm-amd" ];
  };

  # The fstab configurations.
  fileSystems = { 
    "/" = {
      device = "/dev/disk/by-label/SYSTEM";
      fsType = "ext4";
      options = [ "noatime" "nodiratime" ];
    };

  "/boot" = { 
      device = "/dev/disk/by-label/BOOT";
      fsType = "vfat";
      options = [ "fmask=0022" "dmask=0022" ];
    };

  "/home" = { 
      device = "/dev/disk/by-label/HOME";
      fsType = "ext4";
      options = [ "noatime" "nodiratime" ];
    };
  };
 
  # Update AMD CPU microcode.
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  # No swap required, as 32 GB onboard.
  swapDevices = [ ];

  # Some networking configurations.
  networking = {
    hostName = "zephyrus"; 
    useDHCP = lib.mkDefault true;
  };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  # Define zephyrus related services.
  services = {

    # Asusd services for Asus ROG configurations.
    asusd = {
      enable = true;
      enableUserService = true;
    };

    # Enable fstrim on weekly basis.
    fstrim = {
      enable = true;
      interval = "weekly";
    };

    # Use MUX adgpu/nvidia.
    xserver.videoDrivers = [ "amdgpu" "nvidia"]; 
  };

}

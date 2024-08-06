# Helios 500 configurations
{ config, lib, pkgs, modulesPath, ... }: {

  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot = {
    initrd = { 
      availableKernelModules = [ "xhci_pci" "ahci" "usb_storage" "sd_mod" ];
      kernelModules = [ ];
    }; 
    kernelModules = [ "kvm-amd" ];
    extraModulePackages = [ ];
  };

  fileSystems = { 
    "/" = {
      device = "/dev/disk/by-label/SYSTEM";
      fsType = "ext4";
    };
  
    "/nix/store" = {
      device = "/dev/disk/by-label/NIXSTORE";
      fsType = "ext4";
     };
  
    "/home" = {
      device =  "/dev/disk/by-label/HOME";
      fsType = "ext4";
    };
 
    "/boot" = {
      device = "/dev/disk/by-label/BOOT";
      fsType = "vfat";
    };
  };

  swapDevices = [ ];

  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  networking = {
    hostName = "predator";
    interfaces = {
      enp3s0.useDHCP = true;
      wlp4s0.useDHCP = true;
    };
  };
  
  services.xserver.videoDrivers = ["amdgpu"];
}

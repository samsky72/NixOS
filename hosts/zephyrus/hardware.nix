# Zephyrus Duo 16 (2023) configuration.
{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot = {
    initrd = {
      availableKernelModules = [ "nvme" "xhci_pci" "usbhid" "usb_storage" "sd_mod" ];
      kernelModules = [ "dm-snapshot" ];
    };
    kernelModules = [ "kvm-amd" ];
    extraModulePackages = [ ];
  };

  fileSystems."/" = {
     device = "/dev/disk/by-label/SYSTEM";
     fsType = "ext4";
     options = [ "noatime" "nodiratime"];
  };

  fileSystems."/boot" = {
     device = "/dev/disk/by-label/BOOT";
     fsType = "vfat";
     options = [ "fmask=0022" "dmask=0022" ];
  };

  fileSystems."/home" = { 
    device = "/dev/disk/by-label/HOME";
    fsType = "ext4";
    options = [ "noatime" "nodiratime" ];
  };

  swapDevices = [ ];

  environment.systemPackages = with pkgs; [
    asusctl
    supergfxctl
  ];

  powerManagement.enable = true;

  hardware = {
    bluetooth.enable = true;
    nvidia.open = false;
  };

  services = {
    asusd.enable = true;
#    tlp.enable = true;
    upower.enable = true;
    xserver.videoDrivers = [ "amdgpu" "nvidia" ];  
  };
  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking = {
    hostName = "zephyrus";
    useDHCP = lib.mkDefault true;
  };

  # networking.interfaces.enp3s0.useDHCP = lib.mkDefault true;
  # networking.interfaces.wlp4s0.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}

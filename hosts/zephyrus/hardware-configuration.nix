# Zephyrus Duo 16 (2023) configuration (flake-friendly, uses `hostName` from specialArgs).
{ config, lib, pkgs, modulesPath, hostName, ... }:

{
  # Prefer committing ./hardware-configuration.nix after first install:
  # imports = [ ./hardware-configuration.nix ];
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
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
    options = [ "noatime" "nodiratime" ];
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

  # No disk-backed swap here (OK if you use zram elsewhere, or none).
  swapDevices = [ ];

  environment.systemPackages = with pkgs; [
    asusctl
    supergfxctl
  ];

  powerManagement.enable = true;

  hardware = {
    bluetooth.enable = true;
    nvidia.open = false;  # keep proprietary module; flip to true if you want the open one
    cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  };

  services = {
    asusd.enable = true;
    upower.enable = true;
    xserver.videoDrivers = [ "amdgpu" "nvidia" ];
    # tlp.enable = true;  # optional; don’t mix with power-profiles-daemon
  };

  networking = {
    hostName = hostName;          # provided by flake specialArgs
    useDHCP  = lib.mkDefault true;
  };

  # (Removed redundant nixpkgs.hostPlatform; the flake’s `system` already sets it.)
}


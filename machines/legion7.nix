# Legion 7 notebook configurations.
{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot = {
    initrd = {
      availableKernelModules = [ "xhci_pci" "nvme" "usbhid" "usb_storage" "sd_mod" ];
      kernelModules = [ "dm-snapshot" ];
    };
    kernelModules = [ "kvm-intel" ];
    extraModulePackages = [ ];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/BOOT";
    fsType = "vfat";
  };

  fileSystems."/" ={ 
    device = "/dev/disk/by-label/SYSTEM";
    fsType = "ext4";
    options = [ "noatime" "nodiratime" ];
  };

  fileSystems."/home" = { 
    device = "/dev/disk/by-label/HOME";
    fsType = "ext4";
    options = [ "noatime" "nodiratime" ];
  };

  swapDevices = [ ];

  powerManagement.cpuFreqGovernor = lib.mkDefault "ondemand";

  hardware = {
    cpu = {
      intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
    };
    opengl.extraPackages = with pkgs; [          # Add VDPAU support.
      vaapiVdpau
      libvdpau-va-gl
    ]; 
  };
  networking = {
    hostName = "legion";
    useDHCP = false;
    interfaces = {
      enp66s0.useDHCP = true;
      wlp0s20f3.useDHCP = true;
    };
  };
  nixpkgs = {
    overlays = [
      (self: super: {
        blender = super.blender.override {
          cudaSupport = true;                   # Add CUDA support for blender
        };
      })
    ];
  };
  services = {
    fstrim = {
      enable = true;                            # Enable weekly SSD trim.
      interval = "weekly";
    };
    tlp.enable = true;                          # Use TLP daemon for power management.
    upower.enable = true;                       # Use upower for applications power management via D-Bus.
    xserver= {
      videoDrivers = ["nvidia"];                # Use nVidia proprietary driver.
      dpi = 96;                                 # DPI correction.
      libinput = {
        enable = true;                          # Enable touchpad support.
        touchpad.disableWhileTyping = true;     # Disable touchpad while typing.
      };
    };
  }; 
}

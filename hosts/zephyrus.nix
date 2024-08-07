# Zephyrus Duo 16 configurations..
{ config, lib, modulesPath, pkgs, ... }:

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
    kernelModules = [ "i2c-dev" "kvm-amd" ];
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
 
  # Some hardware configurations..
  hardware = {
    cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;                # Update AMD CPU microcode.
    i2c.enable = true;                                                                                    # Add I2C support for keypad/touchpad support.
  };

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

  # Add combined Asus keypad/toucpad support.
  systemd.services.asus-touchpad-numpad = {
    description = "Activate Numpad inside the touchpad with top right corner switch";
    documentation = ["https://github.com/mohamed-badaoui/asus-touchpad-numpad-driver"];
    path = [ pkgs.i2c-tools ];
    script = ''
      cd ${pkgs.fetchFromGitHub {
        owner = "mohamed-badaoui";
        repo = "asus-touchpad-numpad-driver";
        rev = "d80980af6ef776ee6acf42c193689f207caa7968";
        sha256 = "sha256-JM2wrHqJTqCIOhD/yvfbjLZEqdPRRbENv+N9uQHiipc=";
      }}
      # Asus Zephyrus Duo 16 use gx701 layout.
      ${pkgs.python3.withPackages(ps: [ ps.libevdev ])}/bin/python asus_touchpad.py gx701
    '';
    serviceConfig = {
      RestartSec = "1s";
      Restart = "on-failure";
    };
    wantedBy = [ "multi-user.target" ];
  };
}

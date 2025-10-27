# modules/boot.nix
# =============================================================================
# Boot configuration for UEFI systems using systemd-boot and the linux-zen kernel.
#
# Scope:
#   • Configures systemd-boot for EFI firmware
#   • Selects linux-zen kernel and matching modules
#   • Reduces kernel/udev verbosity for a quiet boot
#   • Enables systemd in the initrd
#
# Characteristics:
#   • Host-agnostic; no disk layout assumptions
#   • ESP mount point configurable via boot.loader.efi.efiSysMountPoint
#   • Backlight policy set to ACPI “native” by default
# =============================================================================
{ pkgs, lib, ... }:

{
  boot = {
    ##########################################
    ## Bootloader (UEFI / systemd-boot)
    ##########################################
    loader = {
      systemd-boot = {
        enable = true;           # systemd-boot under EFI firmware
        consoleMode = "max";     # largest available console resolution
        configurationLimit = 10; # retain the most recent N boot entries
      };

      efi.canTouchEfiVariables = true; # management of EFI NVRAM entries
      timeout = 3;                     # seconds before booting the default entry
      # efi.efiSysMountPoint = "/boot";  # ESP mount point (example)
    };

    ##########################################
    ## Kernel selection
    ##########################################
    kernelPackages = pkgs.linuxPackages_zen; # linux-zen kernel and modules

    ##########################################
    ## Kernel parameters (quiet boot)
    ##########################################
    kernelParams = [
      "quiet"                      # suppress most kernel messages
      "loglevel=3"                 # warnings and errors only
      "udev.log_priority=3"        # reduced udev logging
      "rd.udev.log_level=3"        # reduced initramfs udev logging
      "vt.global_cursor_default=0" # hide TTY cursor during boot
      "acpi_backlight=native"      # prefer ACPI native backlight interface
    ];

    ##########################################
    ## Initrd
    ##########################################
    initrd.systemd.enable = true;  # systemd in the initrd

    ##########################################
    ## Optional: Plymouth (splash)
    ##########################################
    # plymouth.enable = true;       # graphical splash screen
  };

  ##########################################
  ## CPU microcode updates (unified)
  ##########################################
  hardware.cpu = {
    amd.updateMicrocode   = lib.mkDefault true;
    intel.updateMicrocode = lib.mkDefault true;
  };
}


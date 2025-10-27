# hosts/zephyrus/hardware-configuration.nix
# =============================================================================
# Zephyrus Duo 16 (2023) — hardware profile (flake-friendly)
#
# Purpose
#   • Define filesystems by label (/ , /home, /boot)
#   • Set up initrd/kernel modules appropriate for this laptop
#   • Provide AMD + NVIDIA hybrid graphics hooks (asusctl/supergfxd, nvidia opts)
#   • Keep configuration host-agnostic; defer policy to modules where possible
#
# Notes
#   • Prefer committing ./hardware-configuration.nix after first install.
#   • Hyprland works best in “Integrated” (AMD-only) mode via supergfxd.
#   • PRIME bus IDs are intentionally commented; fill in only if using Xorg offload/sync.
#   • Nouveau is blacklisted to avoid conflicts with the proprietary NVIDIA driver.
# =============================================================================
{ config, lib, pkgs, modulesPath, hostName, ... }:

{
  ##############################################################################
  ## Imports
  ##############################################################################
  imports = [
    # Fallback auto-detected hardware profile; keep until a committed
    # ./hardware-configuration.nix exists and is imported instead.
    (modulesPath + "/installer/scan/not-detected.nix")

    # ./hardware-configuration.nix
  ];

  ##############################################################################
  ## Boot / kernel
  ##############################################################################
  boot = {
    initrd = {
      # Storage/USB modules required in initrd for this platform.
      availableKernelModules = [ "nvme" "xhci_pci" "usbhid" "usb_storage" "sd_mod" ];

      # Device-mapper snapshot support (e.g., LVM snapshots).
      kernelModules = [ "dm-snapshot" ];
    };

    # Enable AMD KVM module at boot for virtualization (harmless if unused).
    kernelModules = [ "kvm-amd" ];

    # Additional out-of-tree kernel modules (none required here).
    extraModulePackages = [ ];

    # Avoid nouveau vs. nvidia driver conflicts.
    blacklistedKernelModules = [ "nouveau" ];
  };

  ##############################################################################
  ## Filesystems (by label)
  ##############################################################################
  fileSystems."/" = {
    device  = "/dev/disk/by-label/SYSTEM";  # root FS label
    fsType  = "ext4";                        # filesystem type
    options = [ "noatime" "nodiratime" ];    # reduce metadata writes
  };

  fileSystems."/boot" = {
    device  = "/dev/disk/by-label/BOOT";     # EFI system partition label
    fsType  = "vfat";                         # FAT32 for EFI
    options = [ "fmask=0022" "dmask=0022" ]; # sane default perms
  };

  fileSystems."/home" = {
    device  = "/dev/disk/by-label/HOME";     # home partition label
    fsType  = "ext4";
    options = [ "noatime" "nodiratime" ];
  };

  # No disk-backed swap; zram can be configured in a separate module if desired.
  swapDevices = [ ];

  ##############################################################################
  ## Laptop power helpers and ASUS stack
  ##############################################################################
  # Generic power management toggle (pairs with power-profiles-daemon elsewhere).
  powerManagement.enable = true;

  # CLI tools for ASUS laptops and graphics mode switching.
  environment.systemPackages = with pkgs; [
    asusctl      # fan/LED/perf controls for ASUS laptops
    supergfxctl  # switch Integrated/Hybrid/Dedicated GPU modes
  ];

  services = {
    # ASUS daemon backing asusctl; exposes platform controls.
    asusd.enable = true;

    # GPU mode daemon: Integrated (iGPU only), Hybrid, Dedicated (dGPU only).
    supergfxd.enable = true;

    # Xorg driver list (harmless under Wayland; useful as fallback).
    xserver.videoDrivers = [ "amdgpu" "nvidia" ];

    # Battery/fuel gauge service queried by many DEs/applets.
    upower.enable = true;
  };

  ##############################################################################
  ## Graphics (AMD + NVIDIA hybrid)
  ##############################################################################
  hardware = {
    # Bluetooth controller; keep system-wide enablement here.
    bluetooth.enable = true;

    # Microcode updates tied to redistributable firmware availability.
    cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

    # Modern OpenGL/Vulkan umbrella (Mesa, VA-API/Vulkan loaders, etc.).
    graphics.enable = true;

    nvidia = {
      # Keep proprietary stack for maximal compatibility/stability.
      open = false;

      # Required for Wayland/X modesetting (avoids legacy userspace modes).
      modesetting.enable = true;

      # Allow driver to power-manage the dGPU (saves battery when idle).
      powerManagement.enable = true;

      # Install nvidia-settings panel for diagnostics/tweaks.
      nvidiaSettings = true;

      # PRIME offload/sync (Xorg only) — provide actual bus IDs before enabling.
      # Obtain by: `lspci | grep -E "VGA|3D"` then convert to "PCI:BUS:DEV:FN".
      # prime = {
      #   offload.enable = true; # alternative: sync.enable = true;
      #   amdgpuBusId = "PCI:5:0:0";
      #   nvidiaBusId = "PCI:1:0:0";
      # };
    };
  };

  ##############################################################################
  ## Networking (hostname supplied via flake specialArgs)
  ##############################################################################
  networking = {
    hostName = hostName;           # injected per host from flake
    useDHCP  = lib.mkDefault true; # rely on NetworkManager to manage links
  };

  ##############################################################################
  ## Operational notes
  ##############################################################################
  # • Default to supergfxctl “Integrated” for Hyprland (AMD iGPU only):
  #     supergfxctl --mode Integrated && systemctl reboot
  #
  # • Switch modes when needed (requires reboot):
  #     supergfxctl --mode Hybrid|Dedicated && systemctl reboot
  #
  # • For PRIME offload/sync under Xorg:
  #     1) Fill amdgpuBusId/nvidiaBusId above.
  #     2) Enable prime.offload or prime.sync.
  #
  # • Consider CPU scheduler hint for recent AMD CPUs if supported:
  #     boot.kernelParams = [ "amd_pstate=active" ];
}


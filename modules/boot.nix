# modules/boot.nix
{ lib, pkgs, ... }:
{
  # Use systemd-boot for UEFI (recommended on modern machines)
  boot.loader.systemd-boot.enable = true;

  # Allow NixOS to write to UEFI boot variables (register itself)
  boot.loader.efi.canTouchEfiVariables = true;

  # Optional: set default timeout (in seconds) for the boot menu
  boot.loader.timeout = 3;

  # Optional: specify your EFI System Partition mount point
  # (default: /boot)
  # boot.loader.efi.efiSysMountPoint = "/boot";

  # Kernel params (optional tweaks)
  boot.kernelParams = [ "quiet" "loglevel=3" ];

  # Ensure initrd can unlock encrypted drives (if applicable)
  # boot.initrd.luks.devices."cryptroot".device = "/dev/nvme0n1p2";
}

# modules/mtp.nix
# =============================================================================
# MTP (Media Transfer Protocol) support
#
# Scope
#   • Enables reliable Android MTP device access
#   • Installs FUSE/CLI tools for headless/manual mounts
#   • Adds udev rules for wide device/vendor coverage
#
# Characteristics
#   • Host-agnostic; complements existing GVFS/udisks2 setup
#   • Works with file managers using GVFS (Thunar, Nautilus, etc.)
# =============================================================================
{ pkgs, ... }:

{
  ##########################################
  ## Core services (GVFS / udisks2)
  ##########################################
  # GVFS + udisks2 are the common MTP stack used by file managers.
  # If already enabled elsewhere (e.g., sysenv.nix), these are harmless repeats.
  services.gvfs.enable    = true;
  services.udisks2.enable = true;

  ##########################################
  ## udev rules for Android/MTP devices
  ##########################################
  # libmtp ships generic MTP rules; android-udev-rules adds many OEM IDs.
  services.udev.packages = [
    pkgs.libmtp
    pkgs.android-udev-rules
  ];

  ##########################################
  ## CLI / FUSE tools (optional but handy)
  ##########################################
  environment.systemPackages = with pkgs; [
    libmtp         # mtp-detect, mtp-getfile, etc.
    simple-mtpfs   # preferred FUSE MTP
    jmtpfs         # alternative FUSE MTP
    # go-mtpfs     # optional: another FUSE implementation
  ];

  ##########################################
  ## Notes
  ##########################################
  # • With GVFS/udisks2 running, most file managers will show the phone
  #   under “Devices” after unlocking and choosing “File Transfer (MTP)”.
  # • For Thunar auto-mount prompts, ensure services.gvfs.enable = true.
  # • ADB is not required for MTP, but can be enabled if needed:
  #     programs.adb.enable = true;   # optional, unrelated to MTP itself
}


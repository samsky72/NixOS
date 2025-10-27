# modules/mtp.nix
# =============================================================================
# Android (ADB) + MTP support (no deprecated android-udev-rules)
#
# Provides
#   • ADB/fastboot client binaries (android-tools)
#   • Modern ADB device access via programs.adb (installs udev rules + group)
#   • Optional MTP FUSE helpers (jmtpfs, simple-mtpfs)
#   • MTP CLI utilities via libmtp (includes mtp-detect, mtp-sendfile, …)
#
# Notes
#   • android-udev-rules is intentionally NOT used (removed upstream).
#   • GUI MTP browsing relies on services.gvfs + services.udisks2 (already
#     enabled in your sysenv module).
# =============================================================================
{ pkgs, lib, defaultUser ? null, ... }:

{
  ##########################################
  ## Client tools (installed system-wide)
  ##########################################
  environment.systemPackages = with pkgs; [
    android-tools  # adb + fastboot command-line clients
    jmtpfs         # FUSE-based MTP filesystem (manual mount helper)
    simple-mtpfs   # alternative FUSE MTP helper (often faster/stabler)
    libmtp         # MTP library + CLI tools (e.g., mtp-detect, mtp-sendfile)
  ];

  ##########################################
  ## ADB device access (udev rules + group)
  ##########################################
  programs.adb.enable = true;  # installs udev rules and manages "adbusers" group

  # Adds the login user to "adbusers" so `adb devices` can access phones.
  # Guarded by defaultUser presence to avoid evaluation errors on hosts
  # that do not pass defaultUser via specialArgs.
  users.users = lib.mkIf (defaultUser != null) {
    ${defaultUser}.extraGroups = lib.mkAfter [ "adbusers" ];
  };

  ##########################################
  ## Operational notes (not re-declared here)
  ##########################################
  # • MTP browsing in file managers depends on:
  #     services.gvfs.enable = true;
  #     services.udisks2.enable = true;
  #   These are already present in your sysenv module.
  #
  # • After switching configurations, replug the device or reload udev rules:
  #     sudo udevadm control --reload
  #     sudo udevadm trigger
  #
  # • First-time ADB use requires authorizing the host on the phone.
  #   Verify with:
  #     adb kill-server && adb start-server
  #     adb devices
}


# modules/filesystems.nix
# =============================================================================
# Additional filesystems and share clients (tools + initrd support)
#
# Provides
#   • Userspace tooling for common filesystems
#   • Kernel/initrd enablement via boot.supportedFilesystems
#   • Network share clients (CIFS/SMB, NFS, SSHFS)
#   • BitLocker (NTFS) support via cryptsetup --type bitlk (no insecure deps)
#
# Notes
#   • Does not alter the root filesystem; enables mounting/formatting of external media.
#   • Kernel "ntfs3" driver is enabled via "ntfs"; ntfs-3g remains useful for tooling and FUSE.
#   • ZFS is commented due to size and out-of-tree kernel modules.
# =============================================================================
{ pkgs, lib, ... }:
{
  ##########################################
  ## Kernel/initrd support
  ##########################################
  boot.supportedFilesystems = [
    "btrfs"
    "xfs"
    "f2fs"
    "ntfs"   # kernel ntfs3
    "exfat"
    # "zfs"  # enable only when ZFS is in use (see section below)
  ];

  ##########################################
  ## Userspace tools
  ##########################################
  environment.systemPackages = with pkgs; [
    # Native Linux filesystems
    btrfs-progs      # mkfs.btrfs, btrfs check, etc.
    xfsprogs         # mkfs.xfs, xfs_repair, …
    f2fs-tools       # mkfs.f2fs, fsck.f2fs

    # FAT/exFAT/NTFS (common on removable media)
    dosfstools       # mkfs.vfat, fsck.vfat
    exfatprogs       # mkfs.exfat, fsck.exfat
    ntfs3g           # ntfsfix and FUSE mount helper

    # Optical/UDF (optional)
    udftools         # mkudffs, fsck.udf

    # Network share clients
    cifs-utils       # mount.cifs (SMB/CIFS)
    nfs-utils        # mount.nfs (NFSv4 client; NFSv3 may require rpcbind)
    sshfs            # FUSE over SSH

    # BitLocker (NTFS) support without insecure dependencies
    cryptsetup       # cryptsetup open --type bitlk …

    # Disk utilities
    util-linux       # lsblk, blkid, fdisk, wipefs, etc.
    parted
    file
  ];

  ##########################################
  ## FUSE policy (optional)
  ##########################################
  # programs.fuse.userAllowOther = true;

  ##########################################
  ## Optional: ZFS (heavy stack; enable only if required)
  ##########################################
  # boot.supportedFilesystems = lib.mkForce [ "zfs" ];
  # services.zfs.autoScrub.enable = true;
  # services.zfs.trim.enable = true;
  # nixpkgs.config.allowUnfree = true;

  ##########################################
  ## Notes for network filesystems
  ##########################################
  # • CIFS/SMB client requires only cifs-utils. Samba server is configured via services.samba.
  # • NFSv4 client functions with nfs-utils alone. NFSv3 mounts may require:
  #     services.rpcbind.enable = true;
}


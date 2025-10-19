# home/modules/kde-integration.nix
{ pkgs, ... }:
{
  ##########################################
  ## Dolphin + KDE file integration (Wayland-friendly)
  ##
  ## I:
  ## - install Dolphin and KIO extras (smb/sftp/archive/mtp/fuse)
  ## - add KDE/Qt thumbnailers for images, video, pdf/ps/epub, RAW, HEIF/HEIC
  ## - DO NOT touch MIME defaults here (I keep those in home/modules/xdg.nix)
  ## - DO NOT set Qt env vars here (Hyprland module owns those)
  ##########################################

  home.packages = with pkgs; [
    # Core file manager (Qt6)
    kdePackages.dolphin
    kdePackages.kde-cli-tools

    # Protocol/FS handlers (network, archives, mtp, etc.)
    kdePackages.kio-extras
    kdePackages.kio-fuse
    kdePackages.kio-admin
    kdePackages.ark                 # ← Qt6 Ark (replaces removed top-level ark)

    # Thumbnailers used by Dolphin (Qt6)
    kdePackages.ffmpegthumbs
    kdePackages.kdegraphics-thumbnailers
    kdePackages.kimageformats

    # Backends some thumbnailers rely on
    qt6.qtimageformats
    ffmpegthumbnailer
    poppler_utils
    libheif
    libraw
  ];

  ##########################################
  ## Minimal Dolphin defaults (safe)
  ##########################################
  xdg.configFile."dolphinrc".text = ''
    [General]
    ShowPreview=true

    [PreviewSettings]
    MaximumLocalPreviewSize=536870912
    MaximumRemotePreviewSize=536870912
  '';

  ##########################################
  ## Notes
  ##
  ## - If I want Dolphin as default directory opener, I set it in:
  ##     home/modules/xdg.nix (xdg.mimeApps.defaultApplications.inode/directory = "dolphin.desktop";)
  ##
  ## - If previews don’t show, I open Dolphin → Settings → Configure Dolphin → General → Previews,
  ##   enable desired types and bump the size limit.
  ##########################################
}


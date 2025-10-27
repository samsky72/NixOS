# home/modules/xdg.nix
# =============================================================================
# XDG (Home Manager) — user dirs, XDG base dirs, and MIME defaults
#
# Characteristics
#   • Declares XDG user directories (Documents, Downloads, …)
#   • Sets XDG base directories (~/.cache, ~/.config, …)
#   • Declares MIME defaults for common types (images/videos/audio/archives)
#   • Uses Thunar as the default file manager (no Dolphin dependency)
#   • Uses qView as the default image viewer
#   • Keeps defaults and “Open With” alternatives tidy
#
# Notes
#   • Desktop entries referenced here must exist on the system. Adjust where
#     necessary (e.g., PDF/text handlers) to match installed applications.
# =============================================================================
{ config, pkgs, ... }:
{
  ##########################################
  ## XDG user directories (Documents, Downloads, …)
  ##########################################
  xdg.userDirs = {
    enable = true;
    createDirectories = true;

    # Examples (uncomment to customize):
    # desktop   = "${config.home.homeDirectory}/Desktop";
    # documents = "${config.home.homeDirectory}/Docs";
    # downloads = "${config.home.homeDirectory}/DL";
    # pictures  = "${config.home.homeDirectory}/Pictures";
    # music     = "${config.home.homeDirectory}/Music";
    # videos    = "${config.home.homeDirectory}/Videos";
  };

  ##########################################
  ## XDG base directory specification
  ##########################################
  xdg = {
    cacheHome  = "${config.home.homeDirectory}/.cache";
    configHome = "${config.home.homeDirectory}/.config";
    dataHome   = "${config.home.homeDirectory}/.local/share";
    stateHome  = "${config.home.homeDirectory}/.local/state";
  };

  ##########################################
  ## MIME defaults (file associations)
  ##########################################
  # Home Manager manages ~/.config/mimeapps.list.
  # Avoid force-writing a separate mimeapps.list elsewhere.
  xdg.mimeApps = {
    enable = true;

    defaultApplications = {
      # File manager (Thunar)
      "inode/directory"    = [ "thunar.desktop" ];
      "x-directory/normal" = [ "thunar.desktop" ];

      # Web / HTML
      "text/html"             = [ "firefox.desktop" ];
      "x-scheme-handler/http" = [ "firefox.desktop" ];
      "x-scheme-handler/https"= [ "firefox.desktop" ];

      # Images (qView)
      "image/jpeg"    = [ "qview.desktop" ];
      "image/png"     = [ "qview.desktop" ];
      "image/webp"    = [ "qview.desktop" ];
      "image/gif"     = [ "qview.desktop" ];
      "image/tiff"    = [ "qview.desktop" ];
      "image/bmp"     = [ "qview.desktop" ];
      "image/svg+xml" = [ "qview.desktop" ];

      # Video (SMPlayer first, mpv fallback)
      "video/x-matroska" = [ "smplayer.desktop" "mpv.desktop" ];
      "video/mp4"        = [ "smplayer.desktop" "mpv.desktop" ];
      "video/webm"       = [ "smplayer.desktop" "mpv.desktop" ];
      "video/x-msvideo"  = [ "smplayer.desktop" "mpv.desktop" ]; # avi
      "video/quicktime"  = [ "smplayer.desktop" "mpv.desktop" ]; # mov
      "video/mpeg"       = [ "smplayer.desktop" "mpv.desktop" ];
      "video/x-ms-wmv"   = [ "smplayer.desktop" "mpv.desktop" ];

      # Audio
      "audio/mpeg"  = [ "smplayer.desktop" "mpv.desktop" ];
      "audio/flac"  = [ "smplayer.desktop" "mpv.desktop" ];
      "audio/x-wav" = [ "smplayer.desktop" "mpv.desktop" ];
      "audio/ogg"   = [ "smplayer.desktop" "mpv.desktop" ];

      # Documents (set to Zathura by default; change if another viewer is used)
      "application/pdf" = [ "org.pwmt.zathura.desktop" ];

      # Text (use an editor that provides a desktop entry; adjust if needed)
      "text/plain" = [ "nvim.desktop" ];
    };

    associations.added = {
      # “Open With…” alternates (non-default)
      "application/pdf" = [ "org.gnome.Evince.desktop" ];
      "text/plain"      = [ "code.desktop" "org.kde.kate.desktop" ];

      # Optional: torrent handlers (uncomment if a client is installed)
      # "x-scheme-handler/magnet"  = [ "org.qbittorrent.qBittorrent.desktop" ];
      # "application/x-bittorrent" = [ "org.qbittorrent.qBittorrent.desktop" ];
    };
  };
}


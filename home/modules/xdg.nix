# home/modules/xdg.nix
# =============================================================================
# XDG (Home Manager) — user dirs, base dirs, and MIME defaults (Dolphin/Thunar)
# =============================================================================
{ config, pkgs, ... }:
{
  ##########################################
  ## XDG user directories (Documents, Downloads, …)
  ##########################################
  xdg.userDirs = {
    enable = true;
    createDirectories = true;

    # Examples if I ever want custom paths:
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
  # Let Home Manager manage ~/.config/mimeapps.list.
  # Do NOT also force-write your own mimeapps.list, or KDE will see an empty chooser.
  xdg.mimeApps = {
    enable = true;

    # My preferred defaults (Dolphin + SMPlayer + Firefox)
    defaultApplications = {
      # File manager (pick one)
      "inode/directory" = [ "org.kde.dolphin.desktop" ]; # or: [ "thunar.desktop" ]

      # Video (cover common containers)
      "video/x-matroska" = [ "smplayer.desktop" "mpv.desktop" ];
      "video/mp4"        = [ "smplayer.desktop" "mpv.desktop" ];
      "video/webm"       = [ "smplayer.desktop" "mpv.desktop" ];
      "video/x-msvideo"  = [ "smplayer.desktop" "mpv.desktop" ]; # avi
      "video/quicktime"  = [ "smplayer.desktop" "mpv.desktop" ]; # mov
      "video/mpeg"       = [ "smplayer.desktop" "mpv.desktop" ];
      "video/x-ms-wmv"   = [ "smplayer.desktop" "mpv.desktop" ];

      # Audio (optional)
      "audio/mpeg"       = [ "smplayer.desktop" "mpv.desktop" ];
      "audio/flac"       = [ "smplayer.desktop" "mpv.desktop" ];
      "audio/x-wav"      = [ "smplayer.desktop" "mpv.desktop" ];
      "audio/ogg"        = [ "smplayer.desktop" "mpv.desktop" ];

      # Web handlers
      "x-scheme-handler/http"  = [ "firefox.desktop" ];
      "x-scheme-handler/https" = [ "firefox.desktop" ];
    };

    # Extra candidates shown in “Open With” (not the default)
    associations.added = {
      "video/x-matroska" = [ "mpv.desktop" "smplayer.desktop" ];
      "video/mp4"        = [ "mpv.desktop" "smplayer.desktop" ];
      "video/webm"       = [ "mpv.desktop" "smplayer.desktop" ];
      "video/x-msvideo"  = [ "mpv.desktop" "smplayer.desktop" ];
      "video/quicktime"  = [ "mpv.desktop" "smplayer.desktop" ];
      "video/mpeg"       = [ "mpv.desktop" "smplayer.desktop" ];
      "video/x-ms-wmv"   = [ "mpv.desktop" "smplayer.desktop" ];

      "audio/mpeg"       = [ "mpv.desktop" "smplayer.desktop" ];
      "audio/flac"       = [ "mpv.desktop" "smplayer.desktop" ];
      "audio/x-wav"      = [ "mpv.desktop" "smplayer.desktop" ];
      "audio/ogg"        = [ "mpv.desktop" "smplayer.desktop" ];
    };
  };

  ##########################################
  ## IMPORTANT: do NOT force-write mimeapps.list
  ##########################################
  # Remove this if you had it:
  # xdg.configFile."mimeapps.list".force = true;

  ##########################################
  ## Ensure apps (and their .desktop files) exist
  ##########################################
}


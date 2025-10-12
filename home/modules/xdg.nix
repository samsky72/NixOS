# home/modules/xdg.nix
# =============================================================================
# XDG (Home Manager) — my user dirs + XDG base directories
#
# What I want:
# - Ensure my standard user folders (Documents, Downloads, …) exist.
# - Keep my $HOME clean by putting config/cache/data/state under XDG paths.
# - Optionally manage my MIME defaults in one place (commented section below).
#
# Notes:
# - When I set `xdg.userDirs.createDirectories = true`, missing folders are created on switch.
# - The XDG base dirs here are explicit so apps reliably pick them up.
# =============================================================================
{ config, ... }:
{
  ##########################################
  ## XDG user directories (Documents, Downloads, …)
  ##########################################
  xdg.userDirs = {
    enable = true;             # write ~/.config/user-dirs.dirs for my session
    createDirectories = true;  # create missing directories when I activate

    # I can customize any path if I prefer a different structure:
    # desktop   = "${config.home.homeDirectory}/Desktop";
    # documents = "${config.home.homeDirectory}/Docs";
    # downloads = "${config.home.homeDirectory}/DL";
    # pictures  = "${config.home.homeDirectory}/Pictures";
    # music     = "${config.home.homeDirectory}/Music";
    # videos    = "${config.home.homeDirectory}/Videos";

    # Optional extras I might want:
    # publicShare = "${config.home.homeDirectory}/Public";
    # templates   = "${config.home.homeDirectory}/Templates";
  };

  ##########################################
  ## XDG base directory specification
  ##########################################
  # I keep dotfiles and app clutter out of $HOME by using explicit XDG dirs:
  #  - $XDG_CONFIG_HOME : where I store app configs
  #  - $XDG_CACHE_HOME  : where apps put caches
  #  - $XDG_DATA_HOME   : non-config application data
  #  - $XDG_STATE_HOME  : state (logs, histories, etc.)
  xdg = {
    cacheHome  = "${config.home.homeDirectory}/.cache";
    configHome = "${config.home.homeDirectory}/.config";
    dataHome   = "${config.home.homeDirectory}/.local/share";
    stateHome  = "${config.home.homeDirectory}/.local/state";
  };

  ##########################################
  ## (Optional) MIME defaults (file associations)
  ##########################################
  # If I want Home Manager to manage ~/.config/mimeapps.list, I can enable this.
  # I’ll only set defaults for apps I actually have installed to avoid broken entries.
  #
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
  #     "text/plain"              = [ "nvim.desktop" ];                  # or "org.kde.kate.desktop"
  #     "inode/directory"         = [ "org.gnome.Nautilus.desktop" ];    # or "thunar.desktop"
  #     "application/pdf"         = [ "org.gnome.Evince.desktop" ];      # or "org.kde.okular.desktop"
  #     "image/png"               = [ "imv.desktop" ];                   # or "org.gnome.Loupe.desktop"
      "video/x-matroska"          = [ "smplayer.desktop"];
      "video/mp4"                 = [ "smplayer.desktop" ];
      "x-scheme-handler/http"     = [ "firefox.desktop" ];              # or "firefox.desktop"
      "x-scheme-handler/https"    = [ "firefox.desktop" ];
    };
  };
  xdg.configFile."mimeapps.list".force = true;
}


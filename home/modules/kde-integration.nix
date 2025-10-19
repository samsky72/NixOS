{ config, lib, pkgs, ... }:

{
  ############################################
  ## KDE apps & services under Hyprland
  ## - I install core KDE tooling that makes Dolphin/Ark/Okular “just work”
  ## - I run a user polkit agent (needed for mounts, updates, etc.)
  ## - I run KDE Connect’s daemon (tray is optional; I already have Thunar action)
  ## - I make sure Qt speaks Wayland (and can fall back to XCB if needed)
  ############################################

  # ---- Packages I want for a solid KDE app experience ----
  home.packages = with pkgs; [
    # Core file stack
    kdePackages.dolphin                 # file manager
    kdePackages.kio-extras             # sftp/smb/trash/mtp/etc. backends
    kdePackages.kio-fuse               # mounts KIO paths for non-KDE apps
    kdePackages.ark                    # archives
    kdePackages.okular                 # PDFs
    kdePackages.gwenview               # images
    kdePackages.kdegraphics-thumbnailers
    kdePackages.kimageformats          # image codecs for previews

    # KDE Connect CLI/app (daemon started by systemd user service below)
    kdePackages.kdeconnect-kde

    # Qt Wayland backends (KDE6=Qt6; keep Qt5 around for some older apps)
    qt6.qtwayland
    qt5.qtwayland
  ];

  # ---- User polkit agent (needed for GUI auth prompts without Plasma) ----
  # I run polkit-kde-agent as a *user* service so dialogs appear in Hyprland.
  systemd.user.services.polkit-kde-agent = {
    Unit = {
      Description = "Polkit KDE Agent (user)";
      PartOf = [ "graphical-session.target" ];
      After  = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${pkgs.kdePackages.polkit-kde-agent-1}/libexec/polkit-kde-authentication-agent-1";
      Restart = "on-failure";
      RestartSec = 2;
      Slice = "background-graphical.slice";
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };

  # ---- KDE Connect daemon (headless; I already have Thunar sharing action) ----
  # If I prefer a tray, I can also start `kdeconnect-app` or `ayatana-indicator-kdeconnect`.
  systemd.user.services.kdeconnectd = {
    Unit = {
      Description = "KDE Connect Daemon";
      PartOf = [ "graphical-session.target" ];
      After  = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${pkgs.kdePackages.kdeconnect-kde}/libexec/kdeconnectd";
      Restart = "on-failure";
      RestartSec = 2;
      Slice = "background-graphical.slice";
      Environment = "QT_QPA_PLATFORM=wayland;xcb";
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };

  # ---- Optional: start kio-fuse early (usually autospawns, so I keep this off) ----
  # systemd.user.services.kio-fuse = {
  #   Unit = {
  #     Description = "KIO FUSE";
  #     PartOf = [ "graphical-session.target" ];
  #     After  = [ "graphical-session.target" ];
  #   };
  #   Service = {
  #     ExecStart = "${pkgs.kdePackages.kio-fuse}/bin/kio-fuse -d";
  #     Restart = "on-failure";
  #   };
  #   Install.WantedBy = [ "graphical-session.target" ];
  # };

  # ---- Qt on Wayland defaults (with XCB fallback for odd apps) ----
  home.sessionVariables = {
    # Prefer native Wayland; fall back to X11 if a plugin is missing.
    QT_QPA_PLATFORM = "wayland;xcb";

    # I usually let the compositor draw borders, not Qt.
    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";

    # Keep Hyprland identity (some apps sniff these):
    XDG_SESSION_TYPE = "wayland";
    XDG_CURRENT_DESKTOP = "Hyprland";
    XDG_SESSION_DESKTOP = "Hyprland";
  };

  # ---- Make sure there’s a portal stack (Hyprland stays the primary) ----
  # I do NOT add xdg-desktop-portal-kde; Hyprland’s portal should remain default.
  # If I want KDE’s file dialog inside sandboxed apps, I can add it as extra,
  # but keep `config.common.default = [ "hyprland" "gtk" ]` like I already do.

  # ---- Nice-to-haves: integrate Dolphin “Open With” on non-KDE desktops ----
  # On most setups Dolphin works out of the box with KIO Extras above.
}


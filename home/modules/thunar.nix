# home/modules/thunar.nix
# =============================================================================
# Thunar (Home Manager)
#
# Provides:
#   • Thunar + archive + volume plug-ins
#   • A per-user Tumbler thumbnailing daemon (systemd user service)
#   • Thunar as the default file manager via XDG MIME
#   • A small set of Thunar custom actions (UCA)
#
# System prerequisites (handled in system modules, not here):
#   services.udisks2.enable = true;   # device and volume management backend
#   services.gvfs.enable    = true;   # trash, MTP, SMB, and other VFS backends
#
# Notes:
#   • Tumbler runs as a user service to avoid global daemon config and to keep
#     thumbnail helpers on PATH without system-wide tweaks.
#   • gvfs in user packages ensures client bits (gvfs-* tools) exist; the
#     actual backends/runtime come from the system service.
#   • uca.xml lives under ~/.config/Thunar; Home Manager writes it declaratively.
# =============================================================================
{ config, pkgs, lib, ... }:

{
  ##########################################
  ## Packages (Thunar + helpers)
  ##########################################
  # Installs Thunar, its archive/volume plugins, and common thumbnail helpers.
  # gvfs is included on the user side for CLI utilities; the service itself
  # is enabled at the system level (see header).
  home.packages = with pkgs; [
    # Thunar core + plugins
    xfce.thunar
    xfce.thunar-archive-plugin   # integrates "Extract..." into Thunar
    xfce.thunar-volman           # auto-mount / volume manager UI glue
    xarchiver                    # GTK archive manager used by the plugin
    gvfs                         # user-side gvfs tools (gio/mtp/smb helpers)

    # Thumbnailer daemon + helpers used by tumblerd
    xfce.tumbler                 # thumbnailing service (daemon + providers)
    ffmpegthumbnailer            # video thumbnails
    poppler_utils                # PDF thumbnails (pdftoppm)
    libgsf                       # ODF/office file thumbnails
    file                         # file(1) for type hints
  ];

  ##########################################
  ## Per-user Tumbler daemon (systemd user)
  ##########################################
  # Runs tumblerd in the user session. PATH is curated so helpers are found.
  # Logs can be inspected via: `journalctl --user -u tumbler -f`
  systemd.user.services.tumbler = {
    Unit = {
      Description = "Tumbler thumbnailing daemon";
      Documentation = "man:tumblerd(1)";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      # tumblerd lives under libexec in xfce packages on Nixpkgs.
      ExecStart = "${pkgs.xfce.tumbler}/libexec/tumblerd";
      Restart = "on-failure";
      RestartSec = 2;

      # Ensure helper binaries are visible to tumbler providers.
      Environment = "PATH=${lib.makeBinPath [
        pkgs.xfce.tumbler
        pkgs.ffmpegthumbnailer
        pkgs.poppler_utils
        pkgs.libgsf
        pkgs.file
      ]}";
    };
    Install = { WantedBy = [ "default.target" ]; };
  };

  ##########################################
  ## Make Thunar the default file manager
  ##########################################
  # Registers Thunar as the handler for directories. If another module also
  # manages mimeapps, prefer a single owner to avoid churn.
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "inode/directory"    = [ "thunar.desktop" ];
      "x-directory/normal" = [ "thunar.desktop" ]; # legacy alias still used by some apps
    };
  };

  ##########################################
  ## Thunar Custom Actions (UCA)
  ##########################################
  # Place uca.xml in the standard Thunar config directory. Thunar reads and
  # merges it on runtime; unique-id values are arbitrary stable tokens.
  home.file.".config/Thunar/uca.xml".text = ''
    <?xml version="1.0" encoding="UTF-8"?>
    <actions>
      <!-- Open Kitty here
           Scope: directories only
           Notes: %f expands to the selected directory path; quotes handle spaces.
      -->
      <action>
        <icon>utilities-terminal</icon>
        <name>Open Kitty here</name>
        <unique-id>1700000000000001</unique-id>
        <command>kitty --directory="%f"</command>
        <description>Open a terminal in this directory</description>
        <patterns>*</patterns>
        <startup-notify>true</startup-notify>
        <directories/>
      </action>

      <!-- Extract Here (xarchiver with 7z fallback)
           Scope: any file types matching patterns below.
           Notes: Uses xarchiver if present; falls back to 7z for broad coverage.
      -->
      <action>
        <icon>package-x-generic</icon>
        <name>Extract Here</name>
        <unique-id>1700000000000002</unique-id>
        <command>sh -c 'if command -v xarchiver >/dev/null 2>&1; then xarchiver -x "%f" -d .; else 7z x -y "%f"; fi'</command>
        <description>Extract archive into current directory</description>
        <patterns>*.zip;*.7z;*.tar;*.tar.*;*.rar;*.gz;*.bz2;*.xz;*.zst</patterns>
        <startup-notify>true</startup-notify>
        <other-files/>
        <audio-files/>
        <image-files/>
        <video-files/>
      </action>
    </actions>
  '';

  ##########################################
  ## Operational notes / troubleshooting
  ##########################################
  # • Thumbnails:
  #   - Clear cache if previews misbehave:
  #       rm -rf ~/.cache/thumbnails/*
  #   - Live logs:
  #       journalctl --user -u tumbler -f
  #
  # • MTP / SMB:
  #   - Requires system‐level `services.gvfs.enable = true;`.
  #   - Devices appear under /run/user/$UID/gvfs and in Thunar’s sidebar.
  #
  # • “Open terminal here” on Wayland:
  #   - Kitty honors --directory; ensure kitty is on PATH in the user session.
}


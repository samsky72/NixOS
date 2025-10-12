# home/modules/thunar.nix
# =============================================================================
# Thunar (Home Manager)
# - Thunar + plugins + xarchiver
# - Per-user Tumbler daemon via systemd user service (no HM option needed)
# - Thunar as default file manager
# - A couple of custom actions (uca.xml)
# NOTE (system side): in NixOS config, ensure:
#   services.udisks2.enable = true;
#   services.gvfs.enable = true;
# =============================================================================
{ config, pkgs, lib, ... }:

{
  ##########################################
  ## Packages
  ##########################################
  home.packages = with pkgs; [
    xfce.thunar
    xfce.thunar-archive-plugin
    xfce.thunar-volman
    xarchiver
    gvfs

    # Thumbnailer daemon + helpers
    xfce.tumbler            # <-- correct attribute
    ffmpegthumbnailer
    poppler_utils
    libgsf
    file
  ];

  ##########################################
  ## Per-user Tumbler daemon (thumbnails)
  ##########################################
  systemd.user.services.tumbler = {
    Unit = {
      Description = "Tumbler thumbnailing daemon";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${pkgs.xfce.tumbler}/libexec/tumblerd";
      Restart = "on-failure";
      RestartSec = 2;

      # Provide thumbnailer tools on PATH for tumblerd helpers
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
  ## Make Thunar default for folders
  ##########################################
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "inode/directory"     = [ "thunar.desktop" ];
      "x-directory/normal"  = [ "thunar.desktop" ];
    };
  };

  ##########################################
  ## Thunar custom actions (UCA)
  ##########################################
  home.file.".config/Thunar/uca.xml".text = ''
    <?xml version="1.0" encoding="UTF-8"?>
    <actions>
      <!-- Open Kitty here -->
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

      <!-- Extract Here (xarchiver fallback to 7z) -->
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
  ## Reminder (system-side)
  ##########################################
  # In NixOS (system) config:
  #   services.udisks2.enable = true;  # automount/backends
  #   services.gvfs.enable = true;     # trash, mtp, smb, etc.
}


# Default environment configurations.
{ config, pkgs, ... }: {
  environment = {
    sessionVariables = {                          # System wide variables.
      BROWSER = "firefox";
      QT_QPA_PLATFORMTHEME = "qt5ct";
    };
    systemPackages = with pkgs; [                 # System wide packages.
      acpi
      archiver
      avidemux
      betterlockscreen
      blender
      breeze-gtk
      breeze-qt5
      btop
      clementine
      darktable
      dislocker
      dmidecode
      dnsutils
      duf
      dunst
      feh
      ffmpegthumbnailer
      gthumb
      gimp
      glxinfo
      inxi
      jre8
      kdenlive
      libnotify
      libreoffice
      lm_sensors
      lmms
      lxappearance
      lshw
      lsof
      mc
      mpv
      msgviewer
      neofetch
      networkmanager-openvpn
      networkmanagerapplet
      nitrogen
      nodejs
      nomacs
      obs-studio
      p7zip
      pciutils
      polybarFull
      powertop
      psmisc
      pywal
      ranger
      rar
      rofi
      rofi-power-menu
      scrot
      smartmontools
      smtube
      smplayer
      spaceFM
      spotify
      qbittorrent
      qt5ct
      tor
      tor-browser-bundle-bin
      usbutils
      wget
      wineWowPackages.staging
      xarchiver
      xclip
      xfce.thunar
      xfce.thunar-archive-plugin
      xfce.thunar-volman
      xfce.tumbler
      xorg.xbacklight
      xorg.xmessage
      youtube-dl
      yt-dlp
      zathura
      gnome.zenity
    ];
  };
  qt.platformTheme = "qt5ct";                       # Enable qt5ct
}

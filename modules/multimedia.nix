# modules/multimedia.nix
{ pkgs, ... }: {
  ##########################################
  ## Multimedia Configuration
  ##
  ## Provides audio, video, and media codec support.
  ## Uses PipeWire (modern replacement for PulseAudio)
  ## and installs essential multimedia libraries.
  ##########################################

  ##########################################
  ## Audio: PipeWire + WirePlumber
  ##########################################

  # Enable the modern PipeWire audio system
  services.pipewire = {
    enable = true;
    alsa.enable = true;             # ALSA compatibility
    alsa.support32Bit = true;       # for 32-bit apps (e.g., Steam)
    pulse.enable = true;            # PulseAudio compatibility
    jack.enable = true;             # JACK audio support for prosumer apps
  };

  # WirePlumber is the default session manager (preferred over pipewire-media-session)
  services.wireplumber.enable = true;

  ##########################################
  ## Video & Codec Support
  ##########################################
  # Add system-wide codec and media libraries
  environment.systemPackages = with pkgs; [
    ##########################################
    # Audio tools
    ##########################################
    alsa-utils          # CLI sound tools (alsamixer, aplay)

    ##########################################
    # Video playback
    ##########################################
    mpv                 # versatile media player
    ffmpeg              # essential multimedia CLI tool
    yt-dlp              # modern youtube-dl fork

    ##########################################
    # Codecs and libraries
    ##########################################
    gstreamer
    gst-plugins-base
    gst-plugins-good
    gst-plugins-bad
    gst-plugins-ugly
    gst-libav
    libva-utils         # VA-API video acceleration tools
    v4l-utils           # video4linux (webcam utilities)
  ];
}


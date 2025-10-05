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
    gst_all_1.gstreamer
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-good
    gst_all_1.gst-plugins-bad
    gst_all_1.gst-plugins-ugly
    gst_all_1.gst-libav
    libva-utils         # VA-API video acceleration tools
    v4l-utils           # video4linux (webcam utilities)
  ];
}


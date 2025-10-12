# modules/multimedia.nix
{ pkgs, ... }: {
  ##########################################
  ## Multimedia Configuration
  ##
  ## I enable PipeWire (with Pulse/JACK shims) and install a solid
  ## audio/video toolset, codecs, and a few desktop players.
  ##########################################

  ##########################################
  ## Audio: PipeWire + WirePlumber
  ##########################################
  services.pipewire = {
    enable = true;
    alsa.enable = true;             # ALSA compatibility
    alsa.support32Bit = true;       # for 32-bit apps (e.g. Steam)
    pulse.enable = true;            # PulseAudio compatibility
    jack.enable = true;             # JACK shim for pro-audio apps
  };

  ##########################################
  ## Video & Codec Support + Players
  ##########################################
  environment.systemPackages = with pkgs; [
    # ---- Core playback / tools ----
    audacity
    mpv                 # lean, HW-accelerated media player
    smplayer            # GUI front-end for mpv (requested)
    strawberry          # music player / library (requested)
    spotify             # Spotify desktop client (unfree; flake allows it)

    ffmpeg              # essential multimedia CLI tool
    yt-dlp              # modern youtube-dl fork

    # ---- GStreamer stack (many apps rely on these) ----
    gst_all_1.gstreamer
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-good
    gst_all_1.gst-plugins-bad
    gst_all_1.gst-plugins-ugly
    gst_all_1.gst-libav

    # ---- HW accel / camera utils ----
    libva-utils         # VA-API tools (vainfo)
    v4l-utils           # video4linux (webcam utilities)

    # ---- Audio utilities ----
    alsa-utils          # alsamixer, aplay, etc.
  ];

  ##########################################
  ## Fonts (icons for prompts/players)
  ##########################################
  fonts = {
    fontconfig.enable = true;
    packages = with pkgs; [
      nerd-fonts.jetbrains-mono   # JetBrainsMono Nerd Font (icons in prompts/UIs)
    ];
  };

  ##########################################
  ## Tips (GPU / Pro-audio / DRM) — optional
  ##########################################
  # NVIDIA:
  #   - On proprietary drivers I may need VDPAU/VA-API shims:
  #       hardware.graphics.extraPackages = with pkgs; [ vaapiVdpau libvdpau-va-gl ];
  #   - Ensure services.xserver.videoDrivers includes "nvidia" in the host config.
  #
  # AMD/Intel:
  #   - `libva-utils: vainfo` should show a working driver (radeonsi for AMD, iHD/i965 for Intel).
  #
  # Pro-audio/JACK:
  #   - JACK shim is enabled. For ultra-low latency, I also tune CPU governor/IRQ;
  #     rtkit already grants RT priorities.
  #
  # Browser DRM (Widevine):
  #   - Firefox: enable DRM in about:preferences; it downloads Widevine on demand.
  #   - Chrome/Chromium: Chrome bundles Widevine; ungoogled-chromium does not.
  #
  # Virtual camera (OBS → Zoom, etc.):
  #   - Add on a host:
  #       boot.kernelModules = [ "v4l2loopback" ];
  #       boot.extraModulePackages = [ pkgs.linuxPackages.v4l2loopback ];
}


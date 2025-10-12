# modules/multimedia.nix
# =============================================================================
# Multimedia stack (audio/video/codecs) with PipeWire + GStreamer + VA-API.
#
# Goals:
# - Modern audio via PipeWire/WirePlumber (PulseAudio/JACK compatibility).
# - Hardware-accelerated video via the new `hardware.graphics.*` options.
# - Broad codec support (GStreamer bundles + ffmpeg) and useful CLIs.
# - Nerd Font for terminals/editors that benefit from icon glyphs.
#
# Note:
# - This module uses ONLY `hardware.graphics.*` (no legacy `hardware.opengl.*`).
# =============================================================================
{ pkgs, ... }:
{
  ##########################################
  ## Audio: PipeWire + WirePlumber
  ##########################################

  # Allow real-time scheduling for smoother audio under load.
  security.rtkit.enable = true;

  # PipeWire server + WirePlumber session manager with PA/JACK/ALSA compatibility.
  services.pipewire = {
    enable = true;

    pulse.enable = true;   # for PulseAudio clients
    jack.enable  = true;   # for JACK-aware apps

    alsa = {
      enable = true;       # ALSA support
      support32Bit = true; # 32-bit ALSA for legacy/games (e.g., Steam/Wine)
    };

    wireplumber.enable = true;  # explicit for clarity
  };

  ##########################################
  ## Video Acceleration (VA-API/VDPAU/OpenGL)
  ##########################################
  hardware.graphics = {
    enable = true;     # replaces the old hardware.opengl.enable
    enable32Bit = true;# 32-bit DRI for 32-bit apps (Steam/Wine)

    # If your GPU stack needs VA-API/VDPAU translation layers, uncomment:
    # extraPackages = with pkgs; [ vaapiVdpau libvdpau-va-gl ];
    # extraPackages32 = with pkgs.pkgsi686Linux; [ vaapiVdpau libvdpau-va-gl ];
  };

  ##########################################
  ## Multimedia tools & codecs
  ##########################################
  environment.systemPackages = with pkgs; [
    # ---- Audio tools ----
    alsa-utils              # alsamixer, aplay/arecord, speaker-test

    # ---- Players & transcoders ----
    mpv                     # robust media player (VA-API-enabled build)
    ffmpeg                  # encode/decode/transcode swiss army knife
    yt-dlp                  # video downloader (YouTube & many sites)

    # ---- GStreamer codec stacks ----
    # base/good: common codecs; bad/ugly: extended formats; libav: ffmpeg bridge
    gst_all_1.gstreamer
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-good
    gst_all_1.gst-plugins-bad
    gst_all_1.gst-plugins-ugly
    gst_all_1.gst-libav

    # ---- Video acceleration & camera tooling ----
    libva-utils             # `vainfo` to inspect VA-API setup
    v4l-utils               # v4l2-ctl, qv4l2 (webcam controls/tests)

    # (Optional) streaming/capture:
    # obs-studio
  ];

  ##########################################
  ## Fonts (Nerd Font for terminals/editors)
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
  #   - On proprietary drivers you may need VDPAU/VA-API shims:
  #       hardware.graphics.extraPackages = with pkgs; [ vaapiVdpau libvdpau-va-gl ];
  #   - Ensure services.xserver.videoDrivers includes "nvidia" in your host config.
  #
  # AMD/Intel:
  #   - `libva-utils: vainfo` should show a working driver (radeonsi for AMD, iHD/i965 for Intel).
  #
  # Pro-audio/JACK:
  #   - JACK shim is enabled. For ultra-low latency, also tune CPU governor/IRQ;
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


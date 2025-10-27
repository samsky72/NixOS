# modules/multimedia.nix
# =============================================================================
# Multimedia stack (PipeWire / codecs / players)
#
# Scope
#   • Enables PipeWire with PulseAudio and JACK compatibility
#   • Installs common A/V tools, codecs, and players
#   • Provides Wayland-friendly defaults
#
# Characteristics
#   • Host-agnostic; vendor specifics are left optional
#   • Uses WirePlumber as the PipeWire session manager
# =============================================================================
{ pkgs, ... }:

{
  ##########################################
  ## Audio: PipeWire + WirePlumber
  ##########################################
  services.pipewire = {
    enable = true;              # PipeWire core
    wireplumber.enable = true;  # session manager

    alsa.enable = true;         # ALSA compatibility
    alsa.support32Bit = true;   # 32-bit ALSA for legacy/Steam titles
    pulse.enable = true;        # PulseAudio server shim
    jack.enable = true;         # JACK shim for pro-audio apps
  };

  # Disable the legacy PulseAudio daemon (renamed option).
  services.pulseaudio.enable = false;

  # Real-time scheduling for low-latency audio.
  security.rtkit.enable = true;

  ##########################################
  ## Video & codecs + players/tools
  ##########################################
  environment.systemPackages = with pkgs; [
    # Core playback / editors
    mpv                 # hw-accelerated media player
    smplayer            # Qt frontend for mpv
    strawberry          # music player / library manager
    audacity            # audio editor

    # Streaming / download utilities
    ffmpeg
    yt-dlp

    # GStreamer stack (widely used by desktop apps)
    gst_all_1.gstreamer
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-good
    gst_all_1.gst-plugins-bad
    gst_all_1.gst-plugins-ugly
    gst_all_1.gst-libav

    # HW acceleration / camera utils
    libva-utils         # VA-API tooling (vainfo)
    v4l-utils           # webcam utilities

    # Audio utilities / mixers
    alsa-utils          # alsamixer, aplay, arecord
    pavucontrol         # PipeWire/Pulse mixer GUI

    # Players (unfree example; requires allowUnfree elsewhere)
    spotify
  ];

  ##########################################
  ## Graphics helpers (optional, vendor-specific)
  ##########################################
  # For NVIDIA VDPAU/VA-API interop, consider:
  # hardware.graphics.extraPackages = with pkgs; [ vaapiVdpau libvdpau-va-gl ];
  # Ensure the correct driver is enabled in the host GPU module.

  ##########################################
  ## Wayland-friendly defaults
  ##########################################
  environment.sessionVariables = {
    SDL_VIDEODRIVER = "wayland";  # prefer SDL Wayland backend
    QT_QPA_PLATFORM = "wayland";  # prefer Qt Wayland backend
    NIXOS_OZONE_WL  = "1";        # enable Wayland in Chromium/Electron
  };

  ##########################################
  ## Fonts (icons in prompts/players)
  ##########################################
  fonts = {
    fontconfig.enable = true;
    packages = with pkgs; [
      nerd-fonts.jetbrains-mono  # Nerd Font for glyph/icon support
    ];
  };

  ##########################################
  ## Notes (optional features)
  ##########################################
  # • Pro-audio: for ultra-low latency, consider CPU governor/IRQ tuning.
  # • Browser DRM (Widevine):
  #     Firefox: enable DRM in about:preferences (downloads Widevine).
  #     Chrome: bundles Widevine; ungoogled-chromium does not.
  # • Virtual camera (OBS → Zoom, etc.):
  #     boot.kernelModules = [ "v4l2loopback" ];
  #     boot.extraModulePackages = [ pkgs.linuxPackages.v4l2loopback ];
}


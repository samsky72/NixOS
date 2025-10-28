# modules/graphics-apps.nix
# =============================================================================
# Creative / Graphical Applications (system-wide, host-agnostic)
#
# Provides
#   • Blender with CUDA kernels for Cycles (NVIDIA)
#   • Raster/vector/DTP/photo/video tools
#   • OBS Studio for capture/streaming
#   • GL/Vulkan diagnostics
#
# Pin sensitivity
#   • scribus-1.7.x may fail on some nixpkgs revisions; this module prefers a
#     stable 1.6 package when present, otherwise omits Scribus (see comments).
#   • The legacy top-level `kdenlive` alias was removed; use `kdePackages.kdenlive`.
# =============================================================================
{ pkgs, lib, ... }:

let
  # ----------------------------------------
  # Blender with CUDA kernels for Cycles.
  # - Requires proprietary NVIDIA driver elsewhere in system config for GPU render.
  # - No optixSupport flag is used; OptiX is detected at runtime from the driver.
  # ----------------------------------------
  blenderCuda =
    pkgs.blender.override {
      cudaSupport = true;  # build CUDA kernels; remove if your pin lacks this arg
    };

  # ----------------------------------------
  # Kdenlive (Qt 6). The old top-level alias was removed; use kdePackages.
  # ----------------------------------------
  kdenliveQt6 = pkgs.kdePackages.kdenlive;

  # ----------------------------------------
  # Scribus selection:
  # 1) Prefer a stable 1.6 package if the pin exposes it (e.g., scribus_1_6).
  # 2) If `pkgs.scribus` exists AND is < 1.7, use it (older/stable).
  # 3) Otherwise, return null (omit) — 1.7.x may fail to build on this pin.
  # ----------------------------------------
  scribusStableCandidate =
    if pkgs ? scribus_1_6 then
      pkgs.scribus_1_6
    else if pkgs ? scribus && lib.versionOlder (pkgs.scribus.version or "0") "1.7" then
      pkgs.scribus
    else
      null;

in
{
  ##########################################
  ## Applications (installed system-wide)
  ##########################################
  environment.systemPackages =
    lib.concatLists [
      [
        blenderCuda        # 3D DCC; Cycles with CUDA kernels for NVIDIA GPUs

        pkgs.gimp          # raster editor (layers, masks, plugins)
        pkgs.krita         # digital painting / tablet-friendly

        pkgs.inkscape      # vector graphics (SVG)
        # Scribus (DTP) — only include if a stable candidate is available:
      ]
      (lib.optional (scribusStableCandidate != null) scribusStableCandidate)
      [
        pkgs.darktable     # photography RAW workflow (non-destructive)
        pkgs.rawtherapee   # alternative RAW developer

        kdenliveQt6        # non-linear video editor (Qt 6)
        pkgs.obs-studio    # capture/stream; NVENC/VAAPI if drivers available

        pkgs.imagemagick   # image conversion/compositing (CLI tools)
        pkgs.ffmpeg        # A/V transcoding/filters/capture (CLI)

        pkgs.mesa-demos    # OpenGL diagnostics (glxinfo, glxgears)
        pkgs.vulkan-tools  # Vulkan diagnostics (vulkaninfo)
      ]
    ];

  ##########################################
  ## Optional guidance (kept as comments)
  ##########################################
  # • If Scribus is omitted (null above) due to a failing 1.7.x on this pin:
  #     # Enable Flatpak once system-wide (in a system module):
  #     #   services.flatpak.enable = true;
  #     # Then install the upstream Scribus Flatpak:
  #     #   flatpak install flathub net.scribus.Scribus
  #
  # • OBS hardware encoders:
  #     NVENC/VAAPI availability depends on GPU driver + userspace configured
  #     in hardware.graphics / hardware.opengl modules.
  #
  # • AMD/ROCm hosts (alternative Blender build if your pin supports it):
  #     let blenderHip = pkgs.blender.override { hipSupport = true; };
  #     in replace `blenderCuda` with `blenderHip`.
}


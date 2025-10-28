# modules/graphics-apps.nix
# =============================================================================
# Creative / Graphical Applications (system-wide)
#
# Provides
#   • Blender with CUDA + OptiX acceleration (for NVIDIA GPUs)
#   • Common 2D/3D, photo, vector, DTP, video, streaming tools
#   • Diagnostic utilities for OpenGL / Vulkan
#
# Notes
#   • Requires allowUnfree = true (already set) to enable OptiX in Blender.
#   • NVIDIA drivers must be configured in host modules for GPU rendering.
#   • No hardware assumptions; this module only installs applications.
# =============================================================================
{ pkgs, lib, ... }:

let
  # Blender (CUDA/OptiX build) — enables GPU rendering on NVIDIA.
  # - cudaSupport = true      → build kernels for CUDA devices
  # - optixSupport = true     → enable NVIDIA OptiX (unfree)
  # If an AMD/ROCm build is desired on another host, switch to:
  #   pkgs.blender.override { hipSupport = true; }
  blenderCuda = pkgs.blender.override {
    cudaSupport  = true;   # compile with CUDA support (NVIDIA)
    optixSupport = true;   # enable OptiX backend (requires allowUnfree)
  };

  # Video editor choice (uncomment one and comment the other if a single editor
  # is preferred). Both can be installed together; defaults to Kdenlive here.
  videoEditor = pkgs.kdenlive;
  # videoEditor = pkgs.shotcut;
in
{
  ##########################################
  ## Applications (installed system-wide)
  ##########################################
  environment.systemPackages = [
    # --- 3D / DCC --------------------------------------------------------------
    blenderCuda              # 3D creation suite with CUDA + OptiX GPU rendering

    # --- 2D raster editors / painting -----------------------------------------
    pkgs.gimp                # raster image editor (plugins may be added separately)
    pkgs.krita               # digital painting / illustration

    # --- Vector / layout / DTP -------------------------------------------------
    pkgs.inkscape            # vector graphics (SVG authoring)
    pkgs.scribus             # desktop publishing / page layout

    # --- Photography / RAW processing -----------------------------------------
    pkgs.darktable           # photo workflow / RAW developer (non-destructive)
    pkgs.rawtherapee         # RAW image processing (alternative toolchain)

    # --- Screen capture / streaming -------------------------------------------
    pkgs.obs-studio          # streaming/recording; add plugins as needed

    # --- Video editing ---------------------------------------------------------
    videoEditor              # Kdenlive (or Shotcut if switched above)

    # --- Media / conversion helpers -------------------------------------------
    pkgs.imagemagick         # image conversions, compositing, scripting (CLI)
    pkgs.ffmpeg              # audio/video transcoding and filters (CLI)

    # --- Graphics/compute diagnostics -----------------------------------------
    pkgs.mesa-demos          # OpenGL utilities: glxinfo, glxgears, etc.
    pkgs.vulkan-tools        # Vulkan utilities: vulkaninfo, etc.
  ];

  ##########################################
  ## Optional hints (kept as comments)
  ##########################################
  # • Blender add-ons:
  #     Nixpkgs does not bundle most third-party add-ons. Install add-ons
  #     per-user in Blender preferences or vendor them in a custom wrapper.
  #
  # • NVIDIA specifics:
  #     Ensure the NVIDIA driver is enabled in the host (e.g., videoDrivers = [ "nvidia" ]).
  #     For OptiX, allowUnfree must be true (already set in nixpkgs.config).
  #
  # • AMD specifics:
  #     On AMD/ROCm hosts, prefer:
  #       blenderHip = pkgs.blender.override { hipSupport = true; };
  #     and replace `blenderCuda` above with `blenderHip`.
  #
  # • OBS Studio sources/encoders:
  #     Add plugins (browser source, VAAPI/NVENC) as needed. Most are included;
  #     hardware encoders depend on the GPU driver/runtime configuration.
  #
  # • GIMP plugins:
  #     Plugin sets vary by nixpkgs revision. If a with-plugins build is desired,
  #     consider a `gimp-with-plugins` wrapper in a separate module/pin.
}


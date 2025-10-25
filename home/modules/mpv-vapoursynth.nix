# home/modules/vapoursynth-with-mvtools.nix
# =============================================================================
# VapourSynth + MVTools for mpv (Home Manager)
#
# Purpose
#   • Build an mpv with VapourSynth enabled and MVTools preloaded.
#   • Ship a ready interpolation script (mvt.vpy) and wire it into mpv.
#
# Important
#   • This nixpkgs expects:   vapoursynth.withPlugins [ <drv> … ]
#     (list style, not lambda). The code below uses only the list style.
#   • If you later switch to a nixpkgs where a lambda is required, see the
#     commented “NEW-STYLE” snippet near vsWithMvtools.
# =============================================================================
{ pkgs, ... }:

let
  # Locate MVTools in common nixpkgs layouts.
  mvtoolsDrv =
    if pkgs ? vapoursynthPlugins && pkgs.vapoursynthPlugins ? mvtools then
      pkgs.vapoursynthPlugins.mvtools
    else if pkgs ? vapoursynth-mvtools then
      pkgs.vapoursynth-mvtools
    else
      (throw "MVTools not found (tried vapoursynthPlugins.mvtools / vapoursynth-mvtools).");

  # Build a VapourSynth runtime that already contains MVTools.
  # Your nixpkgs uses LIST style:
  #   vapoursynth.withPlugins [ mvtoolsDrv … ]
  vsWithMvtools = pkgs.vapoursynth.withPlugins [ mvtoolsDrv ];

  # NEW-STYLE (for future nixpkgs where a lambda is required):
  # vsWithMvtools = pkgs.vapoursynth.withPlugins (ps: [ ps.mvtools ]);

  # Enable VS support in mpv-unwrapped and pass the runtime above; re-wrap via mpv
  # to keep scripts/ytdl integrations.
  mpvUnwrappedVS = pkgs.mpv-unwrapped.override {
    vapoursynthSupport = true;
    vapoursynth        = vsWithMvtools;
  };

  mpvVS = pkgs.mpv.override {
    mpv            = mpvUnwrappedVS;
    youtubeSupport = true;
  };
in
{
  ##############################################################################
  ## mpv (VapourSynth-enabled)
  ##############################################################################
  programs.mpv = {
    enable  = true;
    package = mpvVS;

    # Keep mpv.conf here to avoid drift.
    # The vf line enables interpolation globally. If you prefer a toggle hotkey,
    # delete `vf` and use the binding shown below.
    config = {
      # profile = "vaapi";        # optional: VAAPI decode
      # gpu-context = "wayland";  # optional: force Wayland
      # hwdec = "auto-safe";      # optional: safe HW decode
      # osd-level = 1;

      # Always-on VapourSynth + MVTools:
      #  - `format=yuv420p` -> format scripts commonly expect
      #  - `vapoursynth=~~/mvt.vpy:4:4` -> VS script plus buffer/prefetch (tune)
      vf = "format=yuv420p,vapoursynth=~~/mvt.vpy:4:4";
    };

    # Optional toggle (use this if you removed the vf line above):
    # bindings."CTRL+SHIFT+1" =
    #   ''vf toggle vapoursynth=~~/mvt.vpy:4:4; show-text "VapourSynth filter toggled"'';
  };

  ##############################################################################
  ## Runtime helpers
  ##############################################################################
  home.packages = [
    vsWithMvtools        # VS runtime (provides vspipe etc.)
    pkgs.yt-dlp          # network playback helper for mpv
    (pkgs.writeShellScriptBin "smplayer" ''
      # SMPlayer prefers X11; forcing Qt to xcb avoids some Wayland quirks.
      exec env QT_QPA_PLATFORM=xcb ${pkgs.smplayer}/bin/smplayer "$@"
    '')
  ];

  ##############################################################################
  ## VapourSynth script (MVTools-based frame interpolation)
  ##
  ## Behavior
  ##   • Reads FPS from mpv’s `video_in` context provided to VS.
  ##   • Skips interpolation if container_fps > 70.
  ##   • Interpolates to 60 fps by default.
  ##
  ## Tuning
  ##   • Lower blksize (8/12) = better motion fidelity, more CPU.
  ##   • `mode` in BlockFPS (2/3) trades artifacts vs. smoothness.
  ##   • `thscd2` raises/lower scene-cut sensitivity.
  ##############################################################################
  home.file.".config/mpv/mvt.vpy".text = ''
    # vim: set ft=python:
    import vapoursynth as vs
    core = vs.core

    if "video_in" in globals():
        clip = video_in
        dst_fps = 60

        # Skip if already high-FPS (e.g., high-refresh gameplay caps)
        if not (container_fps > 70):
            # Build rational FPS for both source and destination
            src_fps_num = int(container_fps * 100000000)
            src_fps_den = 100000000
            dst_fps_num = int(dst_fps * 10000)
            dst_fps_den = 10000

            # Ensure the clip has a defined FPS
            clip = core.std.AssumeFPS(clip, fpsnum=src_fps_num, fpsden=src_fps_den)

            # Motion estimation (MVTools)
            sup  = core.mv.Super(clip, pel=2, hpad=16, vpad=16)
            bvec = core.mv.Analyse(sup, blksize=16, isb=True , chroma=True, search=3, searchparam=1)
            fvec = core.mv.Analyse(sup, blksize=16, isb=False, chroma=True, search=3, searchparam=1)

            # Frame interpolation to 60 fps
            clip = core.mv.BlockFPS(
                clip, sup, bvec, fvec,
                num=dst_fps_num, den=dst_fps_den,
                mode=3, thscd2=12
            )

        clip.set_output()
  '';
  home.file.".config/mpv/mvt.vpy".executable = true;
}


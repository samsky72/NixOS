# home/modules/vapoursynth-with-mvtools.nix
# -----------------------------------------------------------------------------
# I enable VapourSynth+MVTools for mpv without overlays and without duplicate
# file management. `withPlugins` takes a LIST, so I resolve mvtools -> list.
# -----------------------------------------------------------------------------
{ pkgs, ... }:

let
  # I resolve the MVTools plugin across possible nixpkgs layouts.
  mvtools =
    if pkgs ? vapoursynthPlugins && pkgs.vapoursynthPlugins ? mvtools then
      pkgs.vapoursynthPlugins.mvtools
    else if pkgs ? vapoursynth-mvtools then
      pkgs.vapoursynth-mvtools
    else
      (throw "MVTools plugin not found in this nixpkgs input (looked for vapoursynthPlugins.mvtools / vapoursynth-mvtools).");

  # I build a VapourSynth runtime that already contains MVTools.
  vsWithMvtools = pkgs.vapoursynth.withPlugins [ mvtools ];

  # I enable VapourSynth support in the unwrapped mpv and point it at vsWithMvtools.
  mpvUnwrappedVS = pkgs.mpv-unwrapped.override {
    vapoursynthSupport = true;
    vapoursynth = vsWithMvtools;
  };

  # I wrap that into the normal mpv wrapper (keeps scripts/ytdl integration).
  mpvVS = pkgs.mpv.override {
    mpv = mpvUnwrappedVS;
    youtubeSupport = true;
  };
in
{
  # I install the VS-enabled mpv as the user’s mpv.
  programs.mpv = {
    enable = true;
    package = mpvVS;

    # I keep mpv.conf here (not via home.file) to avoid conflicts.
    # If I want a toggle key instead of always-on, remove the `vf` line and
    # add a binding below (see the commented binding).
    config = {
      #      profile = "vaapi";
      #gpu-context = "wayland";
      #hwdec = "auto-safe";
      #osd-level = 1;
      #ytdl = "yes";
      # Always-on interpolation via my VS script (see mvt.vpy below).
      vf = "format=yuv420p,vapoursynth=~~/mvt.vpy:4:4";
    };

    # Optional: hotkey to toggle the VS filter (uncomment if you removed `vf` above).
    # bindings."CTRL+SHIFT+1" =
    #   ''vf toggle vapoursynth=~~/mvt.vpy:4:4; show-text "VapourSynth filter toggled"'';
  };

  # I install the VS bundle (with MVTools) and yt-dlp for network playback.
  home.packages = [
    vsWithMvtools
    pkgs.yt-dlp
    (pkgs.writeShellScriptBin "smplayer" ''
      exec env QT_QPA_PLATFORM=xcb ${pkgs.smplayer}/bin/smplayer "$@"
    '')
  ];

  # Updated VapourSynth script: removed 1080p/size limit; I only skip if >70 fps.
  home.file.".config/mpv/mvt.vpy".text = ''
    # vim: set ft=python:
    import vapoursynth as vs
    core = vs.core

    if "video_in" in globals():
        clip = video_in
        dst_fps = 60

        # I only skip if the content is already high-FPS (>70).
        if not (container_fps > 70):
            # Build rational FPS for both source and destination
            src_fps_num = int(container_fps * 100000000)
            src_fps_den = 100000000
            dst_fps_num = int(dst_fps * 10000)
            dst_fps_den = 10000

            # Ensure the clip has a defined FPS
            clip = core.std.AssumeFPS(clip, fpsnum=src_fps_num, fpsden=src_fps_den)

            # Motion estimation & interpolation (MVTools)
            sup  = core.mv.Super(clip, pel=2, hpad=16, vpad=16)
            bvec = core.mv.Analyse(sup, blksize=16, isb=True , chroma=True, search=3, searchparam=1)
            fvec = core.mv.Analyse(sup, blksize=16, isb=False, chroma=True, search=3, searchparam=1)

            clip = core.mv.BlockFPS(
                clip, sup, bvec, fvec,
                num=dst_fps_num, den=dst_fps_den,
                mode=3, thscd2=12
            )

        clip.set_output()
  '';
  home.file.".config/mpv/mvt.vpy".executable = true;
}


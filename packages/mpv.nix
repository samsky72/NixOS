# Override mpv with vapoursynt, mvtools, youtube support and add 60 fps support.
{ config, pkgs, ... }:
let
  user = "samsky";
in {
  home-manager.users.${user} = {
    # Configuration of mpv to use Vapoursynth script for 60 fps  
    home.file.".config/mpv/mpv.conf".text = ''
    vf=format=yuv420p,vapoursynth=~~/mvt.vpy:4:4 
    '';
    # Script for converting video to motion interpolation with 60 fps on the fly 
    home.file.".config/mpv/mvt.vpy".text = ''
    # vim: set ft=python:

    import vapoursynth as vs
    core = vs.core
    if "video_in" in globals():
      clip = video_in

      dst_fps = 60

    # Skip interpolation for >1080p or 60 Hz content due to performance
    if not (clip.width > 1920 or clip.height > 1080 or container_fps > 70):
      src_fps_num = int(container_fps * 1e8)
      src_fps_den = int(1e8)
      dst_fps_num = int(dst_fps * 1e4)
      dst_fps_den = int(1e4)
      # Needed because clip FPS is missing
      clip = core.std.AssumeFPS(clip, fpsnum = src_fps_num, fpsden = src_fps_den)
      print("Reflowing from ",src_fps_num/src_fps_den," fps to ",dst_fps_num/dst_fps_den," fps.")

      sup  = core.mv.Super(clip, pel=2, hpad=16, vpad=16)
      bvec = core.mv.Analyse(sup, blksize=16, isb=True , chroma=True, search=3, searchparam=1)
      fvec = core.mv.Analyse(sup, blksize=16, isb=False, chroma=True, search=3, searchparam=1)
      clip = core.mv.BlockFPS(clip, sup, bvec, fvec, num=dst_fps_num, den=dst_fps_den, mode=3, thscd2=12)
      clip.set_output()
    '';
    home.file.".config/mpv/mvt.vpy".executable = true;
  };   
  nixpkgs = {
    overlays = [
      (final: prev: {
       mpv = pkgs.wrapMpv (prev.mpv-unwrapped.override {
         vapoursynthSupport = true;
         vapoursynth = prev.vapoursynth.withPlugins ([
           prev.vapoursynth-mvtools
         ]);
       }) { youtubeSupport = true; };
     })
    ]; 
  }; 
}

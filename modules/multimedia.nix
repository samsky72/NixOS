# modules/entertainment.nix
# =============================================================================
# Entertainment stack (system level)
#
# Purpose
#   • Provide common media applications without touching user configs.
#   • Keep SVP optional because the NUR recipe currently points at a dead URL
#     (404 on svp-team.com) and will fail builds until the recipe is updated.
#
# Characteristics
#   • Host-agnostic, safe defaults.
#   • No VLC (per request); uses mpv + helpers instead.
#   • Spotify included (unfree).
# =============================================================================
{ pkgs, lib, ... }:

let
  ##############################################################################
  ## Switches (build-safe toggles)
  ##############################################################################
  # Gate SVP to avoid breaking builds while upstream/NUR URLs churn.
  # Set to true once your NUR pin contains a working SVP recipe.
  enableSVP = false;

  ##############################################################################
  ## NUR lookups (guarded)
  ##############################################################################
  # Defensive helpers: only try to reference NUR if it exists in your overlay.
  hasNUR = pkgs ? nur && builtins.typeOf pkgs.nur == "set";

  # Attempt to resolve SVP package from xddxdd’s NUR repo:
  #   • "svp"      — the manager/GUI
  #   • "svp-mpv"  — mpv with SVP scripts baked in (packaged there)
  svpPkg =
    if hasNUR && lib.hasAttrByPath [ "repos" "xddxdd" "svp" ] pkgs.nur
    then lib.getAttrFromPath [ "repos" "xddxdd" "svp" ] pkgs.nur
    else null;

  svpMpvPkg =
    if hasNUR && lib.hasAttrByPath [ "repos" "xddxdd" "svp-mpv" ] pkgs.nur
    then lib.getAttrFromPath [ "repos" "xddxdd" "svp-mpv" ] pkgs.nur
    else null;

in
{
  ##############################################################################
  ## Applications (system-wide)
  ##############################################################################
  environment.systemPackages =
    with pkgs; [
      # --- Players / libraries -------------------------------------------------
      mpv                # main media player (no system-level config here)
      # jellyfin-media-player # Jellyfin desktop player (optional streaming client)

      # --- Streaming / online -------------------------------------------------
      spotify            # Spotify desktop client (unfree)

      # --- Tools / utilities --------------------------------------------------
      yt-dlp             # video downloader (YouTube, etc.)
      ffmpeg             # A/V swiss army knife (convert, probe, concat)
      kid3               # audio tag editor (MP3/FLAC/…)
      losslesscut-bin    # lossless video/audio cutter (GUI, binary build)
      obs-studio         # recording/streaming (desktop capture, camera)
    ]
    # --- Optional: SVP from NUR (disabled by default) -------------------------
    ++ lib.optionals (enableSVP && svpPkg != null)     [ svpPkg ]
    ++ lib.optionals (enableSVP && svpMpvPkg != null)  [ svpMpvPkg ];

  ##############################################################################
  ## Notes / guidance
  ##############################################################################
  # SVP (SmoothVideo Project):
  #   • The NUR package (xddxdd.svp @ 4.6.263) fetches a tarball that upstream
  #     removed, causing a 404 at build time. That’s why enableSVP = false here.
  #   • To try SVP, set enableSVP = true, rebuild, and if it fails, either:
  #       1) Update your NUR input to a commit where the recipe is fixed, or
  #       2) Locally override the package with the current SVP Linux URL/SHA256.
  #
  #   Example override (put in your flake or a small overlay):
  #     nixpkgs.overlays = [
  #       (final: prev: {
  #         nur = prev.nur // {
  #           repos = prev.nur.repos // {
  #             xddxdd = prev.nur.repos.xddxdd // {
  #               svp = prev.nur.repos.xddxdd.svp.overrideAttrs (_: {
  #                 # Replace with the current URL and fixed-output hash:
  #                 src = prev.fetchurl {
  #                   url = "https://www.svp-team.com/files/svp4-linux.<NEWVER>.tar.bz2";
  #                   sha256 = "<fill-me>";
  #                 };
  #               });
  #             };
  #           };
  #         };
  #       })
  #     ];
  #
  # mpv:
  #   • No system-side config here (you asked to avoid it). Keep any tuning
  #     (scripts, profiles, hwdec) in your Home Manager module.
  #
  # Spotify:
  #   • Requires allowUnfree = true in your nixpkgs config (you already set this).
  #
  # OBS:
  #   • For Wayland capture, `obs-studio` detects PipeWire automatically on NixOS
  #     when `services.pipewire` is enabled (you already have it).
}





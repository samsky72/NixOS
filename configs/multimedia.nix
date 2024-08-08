# Multimedia configurations.
{ config, pkgs, ... }: {
  imports = [
    ../packages/mpv.nix                                   # Use overrided mpv.
  ];

  # Add some multimedia softwares.
  environment.systemPackages = with pkgs; [
    djvulibre                                             # DJVULibre - Libraries for djvu support.
    obs-studio                                            # OBS Studio - Software for video recording.
    nur.repos.xddxdd.svp                                  # SVP - Real time frame rate converter.
    smplayer                                              # SMPlayer - QT frontend for mpv.
    spotify                                               # Spotify - Audio player.
  ];

  # Enable rtkit for pipewire.
  security.rtkit.enable =true;

  # Use pipewire as sound server.
  services.pipewire = {
     enable = true;
     pulse.enable = true;                                 # Enable pulseaudio support.
  };
}

# Multimedia configurations.
{ config, pkgs, ... }: {
  imports = [
    ../packages/mpv.nix                                   # Use overrided mpv.
  ];

  # Add some multimedia softwares.
  environment.systemPackages = with pkgs; [
    djvulibre                                             # DJVULibre - Libraries for djvu support.
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

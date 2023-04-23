# Sound configurations.
{ config, ... }: {
  sound.enable = true;                    # Enable ALSA.
  hardware.pulseaudio = {
    enable = true;                        # Enable Pulse Audio.
    support32Bit = true;                  # With 32 bit support.
  };
}

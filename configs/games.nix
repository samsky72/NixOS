# Some gaming configurations.
{ config, pkgs, ... }: {

  # Some game=ing related softwares.
  environment.systemPackages = with pkgs; [
    mangohud                                              # Real-time game statistics (FPS, CPU/GPU loading statistics, etc.)
  ];
   
  # Add 32 bit graphical libraries.
  hardware.graphics.enable32Bit = true;

  # Enable steam.
  programs.steam.enable = true;
}


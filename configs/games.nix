# Some gaming configurations.
{ config, pkgs, ... }: {

  # Some gaming related softwares.
  environment.systemPackages = with pkgs; [
    mangohud                                              # MangoHud - Real-time game statistics (FPS, CPU/GPU loading statistics, etc.)
    retroarchFull                                         # RetroArch - Multi-platform emulator frontend for libretro cores.
  ];
   
  # Add 32 bit graphical libraries.
  hardware.graphics.enable32Bit = true;
  
  # Enable steam.
  programs.steam.enable = true;
}


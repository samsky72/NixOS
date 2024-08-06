# Some gaming configurations.
{ config, pkgs, ... }: {

   environment.systemPackages = with pkgs; [
     mangohud
   ];
   
   hardware.graphics.enable32Bit = true;
   programs.steam.enable = true;
}


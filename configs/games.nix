# Games software's. 
{ config, pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    dosbox                                      # Use Dosbox and RetroArch.
    retroarchFull
  ];
  programs.steam.enable = true;                 # Use steam
}

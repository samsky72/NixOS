# Plasma configurations
{ config, pkgs, ... }: {

  # The KDE 6 packages.
  environment = {
    plasma6.excludePackages = with pkgs.kdePackages; [ krdp ];
    systemPackages = with pkgs.kdePackages; [
      ark                                                  # Archiver.
      dolphin                                              # File manager.
      gwenview                                             # Photo viewer.
      kate                                                 # Editor.
      kcalc                                                # Calculator.
      krdc                                                 # Remode desktop client.
      konsole                                              # Terminal.
      okular                                               # Document viewer.
      spectacle                                            # Screenshot creator.
    ];
  };

  # Enable KDE Connect.
  programs.kdeconnect.enable = true;

  # Enable sddm and plasma 6.
  services = {
    desktopManager.plasma6.enable = true;
    displayManager.sddm = {
      enable = true;
      enableHidpi = true;
    };
  }; 
}  

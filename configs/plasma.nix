# Plasma configurations
{ pkgs, ... }:{

  # The KDE 6 packages.
  environment = {
    plasma6.excludePackages = with pkgs.kdePackages; [ krdp ];
    systemPackages = with pkgs.kdePackages; [
      ark                                                  # Ark - Archiver.
      dolphin                                              # Dolphin - File manager.
      gwenview                                             # Gwenview - Photo viewer.
      kate                                                 # Kate - Text editor.
      kcalc                                                # KCalc - Calculator.
      krdc                                                 # KRDC - Remode desktop client.
      konsole                                              # Konsole - Terminal.
      okular                                               # Okular - Document viewer.
      spectacle                                            # Spectacle - Screenshot creator.
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

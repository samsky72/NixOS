# Networking configurations.
{ config, pkgs, ... }: {

  environment.systemPackages = with pkgs; [
    dig                                       # Dig - DNS tools.
    teams-for-linux                           # Teams - MS Teams client.
    telegram-desktop                          # Telegram Desktop - Telegram client.
    whatsapp-for-linux                        # WhatsApp - WhatsApp client.               
  ];

  # Enable bluetooth.
  hardware.bluetooth.enable = true;

  # Networkin configurations.
  networking = {
  
    # Firewall configurations. 
    firewall = {
      
      allowedTCPPorts = [
        80                                # Open HTTP.
        443                               # Open HTTPS.
        5222                              # Open WhatsApp.
        8118                              # Open Privoxy.
      ];
      
      allowedTCPPortRanges = [
        { from = 1714; to = 1764; }       # Open KDEConnect.
      ];

      enable = true;
    };

    # Use Network Manager.
    networkmanager.enable = true;    
  };

  # Network related services.
  services = {

    # Privoxy support.
    privoxy = {
      enable = true;
      enableTor = true;
    };

    # TOR support.
    tor = {
      client.enable = true;
      enable = true;
    };
  };
}

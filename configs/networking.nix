# Networking configurations.
{ config, pkgs, ... }: {

  environment.systemPackages = with pkgs; [
    whatsapp-for-linux
  ];

  # Enable bluetooth.
  hardware.bluetooth.enable = true;

  # Networkin configurations.
  networking = {
  
    # Firewall configurations. 
    firewall = {
      allowedTCPPorts = [
        80
        443
        5222
        8118
      ];
      enable = true;
    };

    # Use Network Manager.
    networkmanager.enable = true;    
  };

  services = {
    privoxy = {
      enable = true;
      enableTor = true;
    };
    tor = {
      client.enable = true;
      enable = true;
    };
  };
}

# Network configurations. 
{ config, ... } : {
  networking = {
    networkmanager = {                                  # Configure Network Manager.
      appendNameservers = [ "8.8.8.8" "8.8.4.4" ];      # Add google DNS.
      enable = true;
    };
    firewall = {                                        # Firewall configurations.
      allowedTCPPorts = [ 80 443 ];                     # TCP - Enable http, https.
      allowedTCPPortRanges = [ 
         { from = 1714; to = 1764; }                    # Enable KDEConnect ports.
      ];
      allowedUDPPorts = [ 80 443 ];                     # UDP - Enable http, https,
      allowedUDPPortRanges = [ 
        { from = 1714; to = 1764; }                     # Enable KDEConnect ports.
      ];
      enable = true;
    }; 
  };
}

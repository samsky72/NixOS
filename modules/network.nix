# modules/network.nix
{ pkgs, hostName, ... }: {

  #########################################
  ## Networking Configuration
  #########################################
  ## Provides full networking setup via NetworkManager,
  ## secure firewall defaults, and essential CLI tools for
  ## troubleshooting, monitoring, and connectivity testing.
  #########################################

  networking = {
    # Enable NetworkManager (handles Wi-Fi, Ethernet, VPNs, etc.)
    networkmanager.enable = true;

    # Set system hostname dynamically from flake
    hostName = hostName;

    #########################################
    ## Firewall Configuration
    #########################################
    firewall = {
      enable = true;            # Enable NixOS firewall
      allowedTCPPorts = [ 22 ]; # Allow SSH
      allowedUDPPorts = [ ];    # Default deny for UDP
    };
  };

  #########################################
  ## Boot-time Network Behavior
  #########################################
  # Disable waiting for network initialization during boot
  # to improve startup time (good for laptops).
  systemd.network.wait-online.enable = false;

  #########################################
  ## Network Utilities
  #########################################
  environment.systemPackages = with pkgs; [
    # Basic tools
    curl           # Fetch remote resources over HTTP(S)
    wget           # Lightweight download utility
    inetutils      # Provides ping, hostname, etc.
    iproute2       # Modern replacement for net-tools
    dnsutils       # dig, nslookup, etc.
    mtr            # Traceroute + ping combo for diagnostics
    nmap           # Port scanning / network discovery
    traceroute     # Basic traceroute tool
    tcpdump        # Packet capture utility (requires root)
    netcat         # TCP/UDP testing (aka `nc`)
    socat          # Advanced socket utility
    ethtool        # Query and control network driver settings
    iw             # Wireless interface management
  ];

  programs.kdeconnect.enable = true;
}


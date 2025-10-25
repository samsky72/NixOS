# modules/network.nix
# =============================================================================
# Networking stack (NetworkManager, firewall, /etc/hosts, CLI tools, KDE Connect)
#
# Scope
#   • Enables NetworkManager for Wi-Fi/Ethernet/VPN
#   • Populates /etc/hosts via networking.hosts
#   • Applies restrictive firewall defaults (SSH open) + KDE Connect ranges
#   • Installs a practical set of CLI networking utilities
#   • Enables Avahi (mDNS) for local discovery
#
# Characteristics
#   • Host-agnostic; avoids interface-specific assumptions
#   • Disables “wait-online” to speed up boots under NetworkManager
# =============================================================================
{ pkgs, hostName, ... }:
let
  # Netcat flavor selector:
  #   - pkgs.netcat-openbsd : broadly compatible default (recommended)
  #   - pkgs.netcat-gnu     : required only if the `-e` flag is needed
  nc = pkgs.netcat-openbsd;
in
{
  #########################################
  ## Core networking
  #########################################
  networking = {
    # NetworkManager provides Wi-Fi/Ethernet/VPN management.
    networkmanager.enable = true;

    # Hostname comes from flake specialArgs to keep hosts consistent.
    hostName = hostName;

    #########################################
    ## /etc/hosts (static mappings)
    #########################################
    hosts = {
      # Standard loopback entries (IPv4/IPv6).
      "127.0.0.1" = [ "localhost" "localhost.localdomain" ];
      "::1"       = [ "ip6-localhost" "ip6-loopback" "localhost" ];

      # Optional loopback mapping of the machine hostname.
      "127.0.1.1" = [ hostName ];

      # Examples for LAN services (uncomment and adjust as needed):
      # "192.168.50.10" = [ "nas" "nas.home.arpa" ];
      # "192.168.50.11" = [ "printer" "printer.home.arpa" ];
      # "fd00:1234::10" = [ "nas6" "nas6.home.arpa" ];  # IPv6 ULA example
    };

    #########################################
    ## Firewall policy
    #########################################
    firewall = {
      enable = true;                 # default-deny policy

      # Single ports explicitly allowed:
      allowedTCPPorts = [ 22 ];      # SSH
      allowedUDPPorts = [ ];         # keep empty; open per-service when required

      # KDE Connect uses dynamic per-device ports in this range (TCP + UDP).
      allowedTCPPortRanges = [ { from = 1714; to = 1764; } ];
      allowedUDPPortRanges = [ { from = 1714; to = 1764; } ];
    };

    # Optional resolver policy (disabled by default).
    # nameservers = [ "1.1.1.1" "9.9.9.9" ];
    # search      = [ "home.arpa" ];
    # domain      = "home.arpa";
  };

  #########################################
  ## Boot-time behavior
  #########################################
  systemd.services.NetworkManager-wait-online.enable = false;

  #########################################
  ## mDNS (Avahi) for local discovery
  #########################################
  services.avahi = {
    enable = true;       # mDNS responder (Bonjour/ZeroConf)
    nssmdns4 = true;     # resolve *.local via mDNS (IPv4) through glibc NSS
    openFirewall = true; # open UDP 5353 multicast for mDNS
  };

  #########################################
  ## KDE Connect (GUI device pairing)
  #########################################
  programs.kdeconnect.enable = true;

  #########################################
  ## Command-line networking utilities
  #########################################
  environment.systemPackages = with pkgs; [
    # ----- Core CLI -----
    curl                 # HTTP(S) client
    wget                 # simple downloader
    iproute2             # ip/ss/rt tooling
    dnsutils             # dig/nslookup
    mtr                  # ping + traceroute in one
    nmap                 # scanner (also provides ncat)
    traceroute           # classic traceroute
    tcpdump              # packet capture
    socat                # socket swiss-army knife
    ethtool              # NIC settings/query
    iw                   # wireless tooling
    iputils              # ping/arping/tracepath, etc.
    nc                   # netcat variant selected in let-binding above

    # ----- Throughput / latency -----
    iperf3               # TCP/UDP throughput (unicast)
    fping                # fast/batch ping
    arping               # ARP reachability on LAN
    hping                # craft/test TCP/UDP/ICMP packets
    iperf                # legacy iperf; supports multicast UDP

    # ----- Bandwidth / visibility -----
    bmon                 # link bandwidth monitor
    iftop                # per-host bandwidth top
    nethogs              # per-process bandwidth
    nload                # simple Rx/Tx graphs
    bandwhich            # per-process/connection usage (TUI)

    # ----- Packet capture / inspection -----
    wireshark-cli        # tshark (CLI Wireshark)
    termshark            # TUI Wireshark frontend
    tcpflow              # reconstruct TCP streams
    ngrep                # grep-like matching on packets
    python3Packages.scapy# packet forge/sniff (Python)

    # ----- Scanners / discovery -----
    masscan              # very fast TCP scanner
    rustscan             # fast port scan + nmap handoff
    avahi                # avahi-browse and helpers

    # ----- DNS clients -----
    ldns                 # drill (modern dig alternative)
    knot-dns             # kdig (advanced client)
    dog                  # user-friendly DNS client
    whois                # domain registry lookups

    # ----- HTTP(S) & web testing -----
    httpie               # ergonomic HTTP client
    curlie               # curl with HTTPie-like UX
    aria2                # multi-source downloader
    wget2                # modern wget successor
    websocat             # WebSocket client
    testssl              # TLS/SSL scanner
    openssl              # s_client, cert tools
    gnutls               # gnutls-cli for TLS

    # ----- SSH / VPN helpers -----
    mosh                 # resilient SSH-like shell over UDP
    autossh              # restart SSH tunnels automatically
    sshuttle             # “poor man’s VPN” over SSH
    wireguard-tools      # wg/wg-quick
    openvpn              # VPN client/server
    openconnect          # AnyConnect/GlobalProtect client

    # ----- Services / transfer / SMB -----
    lftp                 # heavy-duty FTP/SFTP client
    rsync                # efficient file sync
    wakeonlan            # send WOL magic packets
    samba                # smbclient and utilities
    cifs-utils           # mount.cifs helpers

    # ----- SNMP & addressing -----
    net-snmp             # snmpwalk/snmpget…
    ipcalc               # IPv4 subnet math
    sipcalc              # IPv4/IPv6 calculator
    grepcidr             # CIDR-aware grep
    net-tools            # legacy ifconfig/netstat (occasionally useful)
  ];

  #########################################
  ## Notes (multicast)
  #########################################
  # iperf3 does not support multicast; use legacy `iperf` for group testing:
  #   Sender:   iperf -u -c 239.1.1.1 -p 5000 -b 10M -t 10
  #   Receiver: iperf -u -s -B 239.1.1.1 -p 5000
}


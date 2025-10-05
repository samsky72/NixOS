# modules/network.nix
{ lib, pkgs, hostName, ... }:
{
  #########################################
  ## Basic networking configuration
  #########################################

  # Enable NetworkManager — handles Wi-Fi, Ethernet, VPNs, etc.
  networking.networkmanager.enable = true;

  # Optional: hostname for this machine
  # (Each host config can override this)
  networking.hostName = hostName;

  # Optional: wireless tweaks (useful on laptops)
  # networking.networkmanager.wifi.backend = "iwd";  # alternative Wi-Fi backend
  # networking.networkmanager.ensureProfiles = true; # ensure NM profiles exist

  # Optional: disable wait for network on boot (boot faster)
  systemd.network.wait-online.enable = false;

  #########################################
  ## Firewall (safe defaults)
  #########################################
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 22 ];  # allow SSH
    allowedUDPPorts = [ ];
  };
}

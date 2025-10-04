{ config, lib, pkgs, ... }: {
  # Journald a bit saner on laptops
  services.journald.extraConfig = ''
    SystemMaxUse=250M
    RuntimeMaxUse=150M
  '';

  # Power tweaks suggestion area (uncomment for laptops)
   services.tlp.enable = true;
}

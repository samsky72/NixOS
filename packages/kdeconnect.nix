# KDEConnect configuration.
{ config, pkgs, ... }:
let 
  user = "samsky";
in {
  environment.systemPackages = with pkgs; [ kdeconnect ];
  home-manager.users.${user}.services.kdeconnect = {
    enable = true;
    indicator = true;
  };
}

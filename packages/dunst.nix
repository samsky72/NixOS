# Dunst configuration.
{ config, pkgs, ... }:
let
  user = "samsky";
in {
  environment.systemPackages = with pkgs; [ dunst ];
  home-manager.users.${user}.services.dunst = {
    enable = true;
    settings = {
      global = {
        width = 300;
        height = 300;
        offset = "30x50";
        origin = "top-right";
        transparency = 20;
      };
    };
  };
}


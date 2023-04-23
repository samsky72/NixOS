# Picom configuration.
{ config, pkgs, ...}:
let
  user = "samsky";
in {
  home-manager.users.${user}.services.picom = {
    enable = true; 
    package =  pkgs.picom-next;
    settings = {
      backend = "glx";
      fading = true;
      shadow = true;
      vsync = true;
    };
  };
}

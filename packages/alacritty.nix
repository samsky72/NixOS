# Alacritty configuration.
{ config, pkgs, ... }:
let
  user = "samsky";
in { 
  environment = {
    sessionVariables = {
      XTERM = "${pkgs.alacritty}/bin/alacritty";
    };
    systemPackages = with pkgs; [alacritty];
  };

  home-manager.users.${user}.programs = {
    alacritty = {
      enable = true;
      settings = {
        font = {
          normal = {
            family = "JetBrainsMono Nerd Font"; 
            style = "Regular";
          };
	  size = 9;
        };
        window = {
          opacity = 0.8;
        };
      };
    };
  };
}

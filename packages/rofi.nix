# Rofi configuration.
{ config, pkgs, ...}: 
let
  user = "samsky";
in {
  environment.systemPackages = with pkgs; [ rofi ];
  home-manager.users.${user}.home.file.".config/rofi/config.rasi".text = ''
    /* Dark theme. */
    @import "~/.cache/wal/colors-rofi-dark"

    /* Light theme. */
    @import "~/.cache/wal/colors-rofi-light"
    
    configuration {
      modi: "window,windowcd,filebrowser,drun,ssh,keys,combi,run";
      combi-modi: "window,windowcd,filebrowser,drun,ssh,keys,run";
    }
  '';
}

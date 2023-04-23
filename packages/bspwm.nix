# BspWM configuration.
{ config, pkgs, ... }:
let
  user = "samsky";
in {
  environment.systemPackages = with pkgs; [ 
    bspwm
    sxhkd
  ];
  home-manager.users.${user} = {
    home.file.".config/bspwm/bspwmrc".executable = true;
    home.file.".config/bspwm/bspwmrc".text = ''
      #!/usr/bin/env bash
      pgrep -x sxhkd > /dev/null || sxhkd &
      wal -i ~/Pictures/Wallpapers/Wallpaper.png
      wal -R
      nitrogen --restore --set-scaled &
      polybar &
      dunst &
      bspc monitor -d     
      # source the colors.
      . "/home/${user}/.cache/wal/colors.sh"
      # Set the border colors.
      bspc config normal_border_color "$color1"
      bspc config active_border_color "$color2"
      bspc config focused_border_color "$color15"
      bspc config presel_feedback_color "$color1"
      bspc config focus_follows_pointer true
      bspc config border_width         3
      bspc config window_gap          15
      bspc config split_ratio          0.60
      bspc config borderless_monocle   false
      bspc config gapless_monocle      false
      bspc rule -a firefox desktop='^2' follow=on
      bspc rule -a Blender desktop='^3' follow=on
      bcps rule -a "spotify" desktop='^4'
      bspc rule -a Steam desktop='^5'
    '';
    home.file.".config/sxhkd/sxhkdrc".source = ../dotfiles/sxhkdrc; 
  };
  services.xserver.windowManager = {
    bspwm.enable = true;
  };
}

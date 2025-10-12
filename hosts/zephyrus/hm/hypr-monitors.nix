# hosts/zephyrus/hm/hypr-monitors.nix
# -----------------------------------------------------------------------------
# I keep ONLY hardware-specific bits here (monitors + wallpapers).
# I must replace the `desc:` strings with exact values from:
#   hyprctl monitors -j | jq -r '.[].description'
# -----------------------------------------------------------------------------
{ config, ... }:
{
  wayland.windowManager.hyprland.settings = {
    ##########################################
    ## Monitors — by DESCRIPTION (scale = 1.0)
    ##########################################
    monitor = [
      # I replace these with my exact descriptors
      # Example from Zephyrus Duo 16:
      "desc:BOE NE160QDM-NM4, 2560x1600@240, 640x0, 1.0"  # laptop (top)
      "desc:BOE 0x0A68,      3840x1100@60,  0x1600, 1.0"  # secondary (bottom)
    ];

    ##########################################
    ## Optional: per-monitor workspace defaults
    ## I keep workspaces persistent and assign them here so Hyprland
    ## does not guess across my two displays.
    ##########################################
    workspace = [
      "1, monitor:desc:BOE NE160QDM-NM4, persistent:true, default:true"
      "2, monitor:desc:BOE NE160QDM-NM4, persistent:true"
      "3, monitor:desc:BOE 0x0A68,      persistent:true, default:true"
      "4, monitor:desc:BOE 0x0A68,      persistent:true"
    ];
  };

  ##########################################
  ## Wallpapers bound by DESCRIPTION
  ##########################################
  services.hyprpaper = {
    enable = true;
    settings = {
      preload = [
        "${config.home.homeDirectory}/.local/share/wallpapers/wall.jpg"
      ];
      wallpaper = [
        "desc:BOE NE160QDM-NM4,${config.home.homeDirectory}/.local/share/wallpapers/wall.jpg"
        "desc:BOE 0x0A68,${config.home.homeDirectory}/.local/share/wallpapers/wall.jpg"
      ];
      ipc = true;
    };
  };
}

